

import 'package:equatable/equatable.dart';

abstract class DiagnosticBookingState extends Equatable {
  const DiagnosticBookingState();
  @override List<Object> get props => [];
}

class DiagnosticBookingInitial extends DiagnosticBookingState {}
class DiagnosticBookingLoading extends DiagnosticBookingState {}
class DiagnosticBookingSuccess extends DiagnosticBookingState {
  final String bookingId;
  const DiagnosticBookingSuccess(this.bookingId);
}
class DiagnosticBookingError extends DiagnosticBookingState {
  final String message;
  const DiagnosticBookingError(this.message);
}