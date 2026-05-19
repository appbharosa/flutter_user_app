

import 'package:equatable/equatable.dart';

abstract class HospitalBookingHistoryEvent extends Equatable {
  const HospitalBookingHistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllBookings extends HospitalBookingHistoryEvent {
  final String language;
  const FetchAllBookings(this.language);
  @override
  List<Object?> get props => [language];
}