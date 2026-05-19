// lib/features/hospital_diagnostic/presentation/bloc/hospital_diagnostic_booking_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../domain/use_cases/book_hospital_diagnostic.dart';
import 'hospital_diagnostic_booking_event.dart';
import 'hospital_diagnostic_booking_state.dart';




class HospitalDiagnosticBookingBloc extends Bloc<HospitalDiagnosticBookingEvent, HospitalDiagnosticBookingState> {
  final BookHospitalDiagnosticUseCase bookHospitalDiagnosticUseCase;

  HospitalDiagnosticBookingBloc({required this.bookHospitalDiagnosticUseCase})
      : super(HospitalDiagnosticInitial()) {
    on<SubmitHospitalDiagnosticEvent>(_onSubmit);
    on<ResetHospitalDiagnosticEvent>((_, emit) => emit(HospitalDiagnosticInitial()));
  }

  Future<void> _onSubmit(SubmitHospitalDiagnosticEvent event, Emitter<HospitalDiagnosticBookingState> emit) async {
    emit(HospitalDiagnosticLoading());
    final result = await bookHospitalDiagnosticUseCase(event.booking);
    result.fold(
          (failure) => emit(HospitalDiagnosticFailure(_mapFailureToMessage(failure))),
          (message) => emit(HospitalDiagnosticSuccess(message)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}