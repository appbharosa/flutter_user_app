import 'package:equatable/equatable.dart';
import 'online_doctor_session.dart';

class OnlineDoctorSlotsResponse extends Equatable {
  final String date;
  final String day;
  final String formattedDate;
  final int totalSessions;
  final int totalSlots;
  final List<OnlineDoctorSession> sessions;

  const OnlineDoctorSlotsResponse({
    required this.date,
    required this.day,
    required this.formattedDate,
    required this.totalSessions,
    required this.totalSlots,
    required this.sessions,
  });

  @override
  List<Object?> get props => [date];
}