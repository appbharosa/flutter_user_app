
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/online_doctor_booking_item.dart';
import '../../../../domain/use_cases/get_online_doctor_bookings.dart';
import 'online_doctor_booking_history_event.dart';
import 'online_doctor_booking_history_state.dart';

class OnlineDoctorBookingHistoryBloc extends Bloc<OnlineDoctorBookingHistoryEvent, OnlineDoctorBookingHistoryState> {
  final GetOnlineDoctorBookingsUseCase getBookingsUseCase;

  OnlineDoctorBookingHistoryBloc({required this.getBookingsUseCase})
      : super(OnlineDoctorBookingHistoryInitial()) {
    on<FetchAllOnlineDoctorBookings>(_onFetchAllBookings);
  }

  Future<void> _onFetchAllBookings(FetchAllOnlineDoctorBookings event, Emitter<OnlineDoctorBookingHistoryState> emit) async {
    emit(OnlineDoctorBookingHistoryLoading());

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
      emit(OnlineDoctorBookingHistoryError(errorMessage));
      return;
    }

    List<OnlineDoctorBookingItem> active = [];
    List<OnlineDoctorBookingItem> completed = [];
    activeResult.fold((_) => {}, (data) => active = data);
    completedResult.fold((_) => {}, (data) => completed = data);

    emit(OnlineDoctorBookingHistoryLoaded(activeBookings: active, completedBookings: completed));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}