

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/diagnostic_booking_fetch_detail.dart';

abstract class DiagnosticBookingFetchDetailState extends Equatable {
  const DiagnosticBookingFetchDetailState();
  @override List<Object> get props => [];
}

class DiagnosticBookingFetchDetailInitial extends DiagnosticBookingFetchDetailState {}
class DiagnosticBookingFetchDetailLoading extends DiagnosticBookingFetchDetailState {}
class DiagnosticBookingFetchDetailLoaded extends DiagnosticBookingFetchDetailState {
  final DiagnosticBookingFetchDetail detail;
  const DiagnosticBookingFetchDetailLoaded(this.detail);
}
class DiagnosticBookingFetchDetailError extends DiagnosticBookingFetchDetailState {
  final String message;
  const DiagnosticBookingFetchDetailError(this.message);
}