import 'package:equatable/equatable.dart';
import '../../../../domain/entities/pharmacy_booking_item.dart';

abstract class PharmacyBookingHistoryState extends Equatable {
  const PharmacyBookingHistoryState();
  @override
  List<Object?> get props => [];
}

class PharmacyBookingHistoryInitial extends PharmacyBookingHistoryState {}

class PharmacyBookingHistoryLoading extends PharmacyBookingHistoryState {}

class PharmacyBookingHistoryLoaded extends PharmacyBookingHistoryState {
  final List<PharmacyBookingItem> ongoingBookings;
  final List<PharmacyBookingItem> completedBookings;
  const PharmacyBookingHistoryLoaded({
    required this.ongoingBookings,
    required this.completedBookings,
  });
  @override
  List<Object?> get props => [ongoingBookings, completedBookings];
}

class PharmacyBookingHistoryError extends PharmacyBookingHistoryState {
  final String message;
  const PharmacyBookingHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}