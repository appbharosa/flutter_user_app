import 'package:user/domain/entities/lab_time_session.dart';
import 'slot_model.dart';

class SessionModel extends LabTimeSession {
  const SessionModel({
    required super.name,
    required super.icon,
    required super.totalSlots,
    required super.availableSlots,
    required super.slots,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final slotsList = json['slots'] as List;
    final slots = slotsList.map((s) => SlotModel.fromJson(s)).toList();
    return SessionModel(
      name: json['session'],
      icon: json['session_icon'],
      totalSlots: json['total_slots'],
      availableSlots: json['available_slots'],
      slots: slots,
    );
  }
}