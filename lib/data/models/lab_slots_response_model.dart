import '../../domain/entities/lab_slots_response.dart';
import 'session_model.dart';

class LabSlotsResponseModel extends LabSlotsResponse {
  const LabSlotsResponseModel({
    required super.date,
    required super.day,
    required super.formattedDate,
    required super.totalSessions,
    required super.totalSlots,
    required super.sessions,
  });

  factory LabSlotsResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final sessionsList = result['sessions'] as List;
    final sessions = sessionsList.map((s) => SessionModel.fromJson(s)).toList();
    return LabSlotsResponseModel(
      date: result['date'],
      day: result['day'],
      formattedDate: result['formatted_date'],
      totalSessions: result['total_sessions'],
      totalSlots: result['total_slots'],
      sessions: sessions,
    );
  }
}