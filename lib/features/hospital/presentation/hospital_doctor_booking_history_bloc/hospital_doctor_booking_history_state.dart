

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/hospital_doctor_booking_item.dart';

abstract class HospitalDoctorBookingHistoryState extends Equatable {
  const HospitalDoctorBookingHistoryState();
  @override
  List<Object?> get props => [];
}

class HospitalDoctorBookingHistoryInitial extends HospitalDoctorBookingHistoryState {}

class HospitalDoctorBookingHistoryLoading extends HospitalDoctorBookingHistoryState {}

class HospitalDoctorBookingHistoryLoaded extends HospitalDoctorBookingHistoryState {
  final List<HospitalDoctorBookingItem> activeBookings;
  final List<HospitalDoctorBookingItem> completedBookings;
  const HospitalDoctorBookingHistoryLoaded({
    required this.activeBookings,
    required this.completedBookings,
  });
  @override
  List<Object?> get props => [activeBookings, completedBookings];
}

class HospitalDoctorBookingHistoryError extends HospitalDoctorBookingHistoryState {
  final String message;
  const HospitalDoctorBookingHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}