
import 'package:equatable/equatable.dart';

abstract class HospitalDoctorBookingHistoryEvent extends Equatable {
  const HospitalDoctorBookingHistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllDoctorBookings extends HospitalDoctorBookingHistoryEvent {
  final String language;
  const FetchAllDoctorBookings(this.language);
  @override
  List<Object?> get props => [language];
}