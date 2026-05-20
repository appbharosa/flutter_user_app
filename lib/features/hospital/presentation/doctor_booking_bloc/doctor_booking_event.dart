import 'package:equatable/equatable.dart';

abstract class DoctorBookingEvent extends Equatable {
  const DoctorBookingEvent();
  @override
  List<Object?> get props => [];
}

class ProcessDoctorBooking extends DoctorBookingEvent {
  final Map<String, dynamic> bookingParams;
  final String paymentType; // 'wallet' or 'online'
  const ProcessDoctorBooking({required this.bookingParams, required this.paymentType});
  @override
  List<Object?> get props => [bookingParams, paymentType];
}