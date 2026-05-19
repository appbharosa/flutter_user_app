
import 'package:equatable/equatable.dart';

abstract class PharmacyBookingHistoryEvent extends Equatable {
  const PharmacyBookingHistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllPharmacyBookings extends PharmacyBookingHistoryEvent {
  final String language;
  const FetchAllPharmacyBookings(this.language);
  @override
  List<Object?> get props => [language];
}