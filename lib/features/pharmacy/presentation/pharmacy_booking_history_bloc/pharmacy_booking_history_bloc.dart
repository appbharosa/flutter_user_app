import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_booking_history_bloc/pharmacy_booking_history_event.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_booking_history_bloc/pharmacy_booking_history_state.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/pharmacy_booking_item.dart';
import '../../../../domain/use_cases/get_pharmacy_bookings.dart';


class PharmacyBookingHistoryBloc extends Bloc<PharmacyBookingHistoryEvent, PharmacyBookingHistoryState> {
  final GetPharmacyBookingsUseCase getBookingsUseCase;

  PharmacyBookingHistoryBloc({required this.getBookingsUseCase})
      : super(PharmacyBookingHistoryInitial()) {
    on<FetchAllPharmacyBookings>(_onFetchAllBookings);
  }

  Future<void> _onFetchAllBookings(FetchAllPharmacyBookings event, Emitter<PharmacyBookingHistoryState> emit) async {
    emit(PharmacyBookingHistoryLoading());

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
      emit(PharmacyBookingHistoryError(errorMessage));
      return;
    }

    List<PharmacyBookingItem> ongoing = [];
    List<PharmacyBookingItem> completed = [];
    ongoingResult.fold((_) => {}, (data) => ongoing = data);
    completedResult.fold((_) => {}, (data) => completed = data);

    emit(PharmacyBookingHistoryLoaded(ongoingBookings: ongoing, completedBookings: completed));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}