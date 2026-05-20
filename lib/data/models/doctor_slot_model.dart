import '../../domain/entities/doctor_slot.dart';

class DoctorSlotModel extends DoctorSlot {
  DoctorSlotModel({
    required super.slotId,
    required super.time,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    required super.isBooked,
  });

  factory DoctorSlotModel.fromJson(Map<String, dynamic> json) {
    return DoctorSlotModel(
      slotId: json['slot_id'] ?? 0,
      time: json['time'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] ?? false,
      isBooked: json['is_booked'] ?? false,
    );
  }
}

class DoctorSessionModel extends DoctorSession {
  DoctorSessionModel({
    required super.session,
    required super.sessionIcon,
    required super.totalSlots,
    required super.availableSlots,
    required super.slots,
  });

  factory DoctorSessionModel.fromJson(Map<String, dynamic> json) {
    final slotsList = json['slots'] as List? ?? [];
    return DoctorSessionModel(
      session: json['session'] ?? '',
      sessionIcon: json['session_icon'] ?? '',
      totalSlots: json['total_slots'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
      slots: slotsList.map((s) => DoctorSlotModel.fromJson(s)).toList(),
    );
  }
}

class DoctorSlotsResponseModel extends DoctorSlotsResponse {
  DoctorSlotsResponseModel({
    required super.date,
    required super.day,
    required super.formattedDate,
    required super.totalSessions,
    required super.totalSlots,
    required super.sessions,
  });

  factory DoctorSlotsResponseModel.fromJson(Map<String, dynamic> json) {
    final sessionsList = json['sessions'] as List? ?? [];
    return DoctorSlotsResponseModel(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
      totalSessions: json['total_sessions'] ?? 0,
      totalSlots: json['total_slots'] ?? 0,
      sessions: sessionsList.map((s) => DoctorSessionModel.fromJson(s)).toList(),
    );
  }
}