import 'package:equatable/equatable.dart';

class MedicineBookingResponse extends Equatable {
  final bool success;
  final String message;
  final String? bookingId;

  const MedicineBookingResponse({
    required this.success,
    required this.message,
    this.bookingId,
  });

  @override
  List<Object?> get props => [success, message, bookingId];
}