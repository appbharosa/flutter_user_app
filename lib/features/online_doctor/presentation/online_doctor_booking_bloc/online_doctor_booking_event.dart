
import 'package:equatable/equatable.dart';

abstract class OnlineDoctorBookingEvent extends Equatable {
  const OnlineDoctorBookingEvent();
  @override
  List<Object?> get props => [];
}

class ProcessOnlineDoctorBooking extends OnlineDoctorBookingEvent {
  final Map<String, dynamic> bookingParams;
  final String paymentType; // 'wallet' or 'online'
  const ProcessOnlineDoctorBooking({required this.bookingParams, required this.paymentType});
  @override
  List<Object?> get props => [bookingParams, paymentType];
}