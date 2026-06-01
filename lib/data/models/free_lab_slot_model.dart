import '../../domain/entities/free_lab_slot.dart';

class FreeLabSlotModel extends FreeLabSlot {
  FreeLabSlotModel({
    required super.slotId,
    required super.time,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    required super.isBooked,
  });

  factory FreeLabSlotModel.fromJson(Map<String, dynamic> json) {
    return FreeLabSlotModel(
      slotId: json['slot_id'] ?? 0,
      time: json['time'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] ?? false,
      isBooked: json['is_booked'] ?? false,
    );
  }
}

class FreeLabSessionModel extends FreeLabSession {
  FreeLabSessionModel({
    required super.session,
    required super.sessionIcon,
    required super.totalSlots,
    required super.availableSlots,
    required super.slots,
  });

  factory FreeLabSessionModel.fromJson(Map<String, dynamic> json) {
    final slotsList = json['slots'] as List? ?? [];
    return FreeLabSessionModel(
      session: json['session'] ?? '',
      sessionIcon: json['session_icon'] ?? '',
      totalSlots: json['total_slots'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
      slots: slotsList.map((s) => FreeLabSlotModel.fromJson(s)).toList(),
    );
  }
}

class FreeLabSlotResponseModel extends FreeLabSlotResponse {
  FreeLabSlotResponseModel({
    required super.date,
    required super.day,
    required super.formattedDate,
    required super.totalSessions,
    required super.totalSlots,
    required super.sessions,
  });

  factory FreeLabSlotResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final sessionsList = result['sessions'] as List? ?? [];
    return FreeLabSlotResponseModel(
      date: result['date'] ?? '',
      day: result['day'] ?? '',
      formattedDate: result['formatted_date'] ?? '',
      totalSessions: result['total_sessions'] ?? 0,
      totalSlots: result['total_slots'] ?? 0,
      sessions: sessionsList.map((s) => FreeLabSessionModel.fromJson(s)).toList(),
    );
  }
}