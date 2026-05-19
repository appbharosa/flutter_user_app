// lib/features/hospital_booking_history/presentation/bloc/hospital_booking_history_state.dart

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/hospital_diagnostic_booking_item.dart';

abstract class HospitalBookingHistoryState extends Equatable {
  const HospitalBookingHistoryState();
  @override
  List<Object?> get props => [];
}

class HospitalBookingHistoryInitial extends HospitalBookingHistoryState {}

class HospitalBookingHistoryLoading extends HospitalBookingHistoryState {}

class HospitalBookingHistoryLoaded extends HospitalBookingHistoryState {
  final List<HospitalDiagnosticBookingItem> ongoingBookings;
  final List<HospitalDiagnosticBookingItem> completedBookings;

  const HospitalBookingHistoryLoaded({
    required this.ongoingBookings,
    required this.completedBookings,
  });

  @override
  List<Object?> get props => [ongoingBookings, completedBookings];
}

class HospitalBookingHistoryError extends HospitalBookingHistoryState {
  final String message;
  const HospitalBookingHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}