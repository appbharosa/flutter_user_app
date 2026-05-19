import 'package:equatable/equatable.dart';

abstract class OnlineDoctorBookingHistoryEvent extends Equatable {
  const OnlineDoctorBookingHistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllOnlineDoctorBookings extends OnlineDoctorBookingHistoryEvent {
  final String language;
  const FetchAllOnlineDoctorBookings(this.language);
  @override
  List<Object?> get props => [language];
}