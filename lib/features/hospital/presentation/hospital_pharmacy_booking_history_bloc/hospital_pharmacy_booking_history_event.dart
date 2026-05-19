

import 'package:equatable/equatable.dart';

abstract class HospitalPharmacyBookingHistoryEvent extends Equatable {
  const HospitalPharmacyBookingHistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllPharmacyBookings extends HospitalPharmacyBookingHistoryEvent {
  final String language;
  const FetchAllPharmacyBookings(this.language);
  @override
  List<Object?> get props => [language];
}