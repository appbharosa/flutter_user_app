
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/hospital_pharmacy_booking_item.dart';
import '../../../../domain/use_cases/get_hospital_pharmacy_bookings.dart';
import 'hospital_pharmacy_booking_history_event.dart';
import 'hospital_pharmacy_booking_history_state.dart';


class HospitalPharmacyBookingHistoryBloc
    extends Bloc<HospitalPharmacyBookingHistoryEvent, HospitalPharmacyBookingHistoryState> {
  final GetHospitalPharmacyBookingsUseCase getBookingsUseCase;

  HospitalPharmacyBookingHistoryBloc({required this.getBookingsUseCase})
      : super(HospitalPharmacyBookingHistoryInitial()) {
    on<FetchAllPharmacyBookings>(_onFetchAllBookings);
  }

  Future<void> _onFetchAllBookings(
      FetchAllPharmacyBookings event, Emitter<HospitalPharmacyBookingHistoryState> emit) async {
    emit(HospitalPharmacyBookingHistoryLoading());

    final results = await Future.wait([
      getBookingsUseCase.getOngoing(event.language),
      getBookingsUseCase.getCompleted(event.language),
    ]);

    final ongoingResult = results[0];
    final completedResult = results[1];

    if (ongoingResult.isLeft() || completedResult.isLeft()) {
      String errorMessage = '';
      ongoingResult.fold((failure) => errorMessage = _mapFailureToMessage(failure), (_) => {});
      if (errorMessage.isEmpty) {
        completedResult.fold((failure) => errorMessage = _mapFailureToMessage(failure), (_) => {});
      }
      emit(HospitalPharmacyBookingHistoryError(errorMessage));
      return;
    }

    List<HospitalPharmacyBookingItem> ongoing = [];
    List<HospitalPharmacyBookingItem> completed = [];
    ongoingResult.fold((_) => {}, (data) => ongoing = data);
    completedResult.fold((_) => {}, (data) => completed = data);

    emit(HospitalPharmacyBookingHistoryLoaded(
      ongoingBookings: ongoing,
      completedBookings: completed,
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}