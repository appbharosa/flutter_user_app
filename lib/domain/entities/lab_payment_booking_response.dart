import 'package:equatable/equatable.dart';

class LabPaymentBookingResponse extends Equatable {
  final int bookingId;
  final String bookingStatus;
  final String paymentStatus;

  const LabPaymentBookingResponse({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [bookingId, bookingStatus, paymentStatus];
}