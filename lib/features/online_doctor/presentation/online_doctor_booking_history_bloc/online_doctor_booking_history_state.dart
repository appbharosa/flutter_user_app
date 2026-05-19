

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/online_doctor_booking_item.dart';

abstract class OnlineDoctorBookingHistoryState extends Equatable {
  const OnlineDoctorBookingHistoryState();
  @override
  List<Object?> get props => [];
}

class OnlineDoctorBookingHistoryInitial extends OnlineDoctorBookingHistoryState {}

class OnlineDoctorBookingHistoryLoading extends OnlineDoctorBookingHistoryState {}

class OnlineDoctorBookingHistoryLoaded extends OnlineDoctorBookingHistoryState {
  final List<OnlineDoctorBookingItem> activeBookings;
  final List<OnlineDoctorBookingItem> completedBookings;
  const OnlineDoctorBookingHistoryLoaded({
    required this.activeBookings,
    required this.completedBookings,
  });
  @override
  List<Object?> get props => [activeBookings, completedBookings];
}

class OnlineDoctorBookingHistoryError extends OnlineDoctorBookingHistoryState {
  final String message;
  const OnlineDoctorBookingHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}