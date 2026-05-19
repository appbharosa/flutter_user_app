// lib/features/ambulance_booking/presentation/bloc/ambulance_booking_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/use_cases/book_ambulance.dart';
import 'ambulance_booking_event.dart';
import 'ambulance_booking_state.dart';


class AmbulanceBookingBloc extends Bloc<AmbulanceBookingEvent, AmbulanceBookingState> {
  final BookAmbulanceUseCase bookAmbulanceUseCase;

  AmbulanceBookingBloc({required this.bookAmbulanceUseCase})
      : super(AmbulanceBookingInitial()) {
    on<SubmitAmbulanceBooking>(_onSubmit);
    on<ResetAmbulanceBooking>((_, emit) => emit(AmbulanceBookingInitial()));
  }

  Future<void> _onSubmit(SubmitAmbulanceBooking event, Emitter<AmbulanceBookingState> emit) async {
    emit(AmbulanceBookingLoading());
    final result = await bookAmbulanceUseCase(
      language: event.language,
      mainDataId: event.mainDataId,
    );
    result.fold(
          (failure) => emit(AmbulanceBookingFailure(_mapFailureToMessage(failure))),
          (booking) => emit(AmbulanceBookingSuccess(booking.bookingId)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}