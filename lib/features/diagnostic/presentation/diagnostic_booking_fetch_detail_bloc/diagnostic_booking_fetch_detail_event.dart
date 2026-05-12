
import 'package:equatable/equatable.dart';

abstract class DiagnosticBookingFetchDetailEvent extends Equatable {
  const DiagnosticBookingFetchDetailEvent();
  @override List<Object> get props => [];
}

class LoadFetchBookingDetail extends DiagnosticBookingFetchDetailEvent {
  final String bookingId;
  const LoadFetchBookingDetail(this.bookingId);
  @override List<Object> get props => [bookingId];
}