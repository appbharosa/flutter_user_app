

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/hospital_pharmacy_booking_item.dart';

abstract class HospitalPharmacyBookingHistoryState extends Equatable {
  const HospitalPharmacyBookingHistoryState();
  @override
  List<Object?> get props => [];
}

class HospitalPharmacyBookingHistoryInitial extends HospitalPharmacyBookingHistoryState {}

class HospitalPharmacyBookingHistoryLoading extends HospitalPharmacyBookingHistoryState {}

class HospitalPharmacyBookingHistoryLoaded extends HospitalPharmacyBookingHistoryState {
  final List<HospitalPharmacyBookingItem> ongoingBookings;
  final List<HospitalPharmacyBookingItem> completedBookings;
  const HospitalPharmacyBookingHistoryLoaded({
    required this.ongoingBookings,
    required this.completedBookings,
  });
  @override
  List<Object?> get props => [ongoingBookings, completedBookings];
}

class HospitalPharmacyBookingHistoryError extends HospitalPharmacyBookingHistoryState {
  final String message;
  const HospitalPharmacyBookingHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}