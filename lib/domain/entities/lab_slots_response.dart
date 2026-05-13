import 'package:equatable/equatable.dart';
import 'package:user/domain/entities/lab_time_session.dart';


class LabSlotsResponse extends Equatable {
  final String date;
  final String day;
  final String formattedDate;
  final int totalSessions;
  final int totalSlots;
  final List<LabTimeSession> sessions;

  const LabSlotsResponse({
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