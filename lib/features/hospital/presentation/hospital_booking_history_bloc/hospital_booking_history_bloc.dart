import 'package:bloc/bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/hospital_diagnostic_booking_item.dart';
import '../../../../domain/use_cases/get_hospital_diagnostic_bookings.dart';
import 'hospital_booking_history_event.dart';
import 'hospital_booking_history_state.dart';




class HospitalBookingHistoryBloc extends Bloc<HospitalBookingHistoryEvent, HospitalBookingHistoryState> {
  final GetHospitalDiagnosticBookingsUseCase getBookingsUseCase;

  HospitalBookingHistoryBloc({required this.getBookingsUseCase}) : super(HospitalBookingHistoryInitial()) {
    on<FetchAllBookings>(_onFetchAllBookings);
  }

  Future<void> _onFetchAllBookings(FetchAllBookings event, Emitter<HospitalBookingHistoryState> emit) async {
    emit(HospitalBookingHistoryLoading());

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
      emit(HospitalBookingHistoryError(errorMessage));
      return;
    }

    List<HospitalDiagnosticBookingItem> ongoing = [];
    List<HospitalDiagnosticBookingItem> completed = [];
    ongoingResult.fold((_) => {}, (data) => ongoing = data);
    completedResult.fold((_) => {}, (data) => completed = data);

    emit(HospitalBookingHistoryLoaded(ongoingBookings: ongoing, completedBookings: completed));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}