
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/hospital_doctor_booking_item.dart';
import '../../../../domain/use_cases/get_hospital_doctor_bookings.dart';
import 'hospital_doctor_booking_history_event.dart';
import 'hospital_doctor_booking_history_state.dart';


class HospitalDoctorBookingHistoryBloc
    extends Bloc<HospitalDoctorBookingHistoryEvent, HospitalDoctorBookingHistoryState> {
  final GetHospitalDoctorBookingsUseCase getBookingsUseCase;

  HospitalDoctorBookingHistoryBloc({required this.getBookingsUseCase})
      : super(HospitalDoctorBookingHistoryInitial()) {
    on<FetchAllDoctorBookings>(_onFetchAllBookings);
  }

  Future<void> _onFetchAllBookings(
      FetchAllDoctorBookings event, Emitter<HospitalDoctorBookingHistoryState> emit) async {
    emit(HospitalDoctorBookingHistoryLoading());

    final results = await Future.wait([
      getBookingsUseCase.getActive(event.language),
      getBookingsUseCase.getCompleted(event.language),
    ]);

    final activeResult = results[0];
    final completedResult = results[1];

    if (activeResult.isLeft() || completedResult.isLeft()) {
      String errorMessage = '';
      activeResult.fold((failure) => errorMessage = _mapFailureToMessage(failure), (_) => {});
      if (errorMessage.isEmpty) {
        completedResult.fold((failure) => errorMessage = _mapFailureToMessage(failure), (_) => {});
      }
      emit(HospitalDoctorBookingHistoryError(errorMessage));
      return;
    }

    List<HospitalDoctorBookingItem> active = [];
    List<HospitalDoctorBookingItem> completed = [];
    activeResult.fold((_) => {}, (data) => active = data);
    completedResult.fold((_) => {}, (data) => completed = data);

    emit(HospitalDoctorBookingHistoryLoaded(
      activeBookings: active,
      completedBookings: completed,
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}