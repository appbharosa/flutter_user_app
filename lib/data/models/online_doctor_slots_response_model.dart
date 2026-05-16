import '../../domain/entities/online_doctor_slots_response.dart';
import 'online_doctor_session_model.dart';

class OnlineDoctorSlotsResponseModel extends OnlineDoctorSlotsResponse {
  const OnlineDoctorSlotsResponseModel({
    required super.date,
    required super.day,
    required super.formattedDate,
    required super.totalSessions,
    required super.totalSlots,
    required super.sessions,
  });

  factory OnlineDoctorSlotsResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final sessionsList = result['sessions'] as List;
    final sessions = sessionsList.map((s) => OnlineDoctorSessionModel.fromJson(s)).toList();
    return OnlineDoctorSlotsResponseModel(
      date: result['date'],
      day: result['day'],
      formattedDate: result['formatted_date'],
      totalSessions: result['total_sessions'],
      totalSlots: result['total_slots'],
      sessions: sessions,
    );
  }
}