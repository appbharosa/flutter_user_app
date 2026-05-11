import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/book_diagnostic_usecase.dart';
import 'diagnostic_booking_event.dart';
import 'diagnostic_booking_state.dart';


class DiagnosticBookingBloc extends Bloc<DiagnosticBookingEvent, DiagnosticBookingState> {
  final BookDiagnosticUseCase bookDiagnosticUseCase;
  DiagnosticBookingBloc({required this.bookDiagnosticUseCase}) : super(DiagnosticBookingInitial()) {
    on<BookDiagnosticEvent>(_onBookDiagnostic);
  }

  Future<void> _onBookDiagnostic(BookDiagnosticEvent event, Emitter<DiagnosticBookingState> emit) async {
    emit(DiagnosticBookingLoading());
    final result = await bookDiagnosticUseCase(BookDiagnosticParams(
      diagnosticId: event.diagnosticId,
      prescriptionPaths: event.prescriptionPaths,
      lang: event.lang,
      familyMemberId: event.familyMemberId,
    ));
    result.fold(
          (failure) => emit(DiagnosticBookingError(failure.message)),
          (response) => emit(DiagnosticBookingSuccess(response.bookingId)),
    );
  }
}