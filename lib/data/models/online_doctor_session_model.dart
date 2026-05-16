import '../../domain/entities/online_doctor_session.dart';
import 'online_doctor_slot_model.dart';

class OnlineDoctorSessionModel extends OnlineDoctorSession {
  const OnlineDoctorSessionModel({
    required super.name,
    required super.icon,
    required super.totalSlots,
    required super.availableSlots,
    required super.slots,
  });

  factory OnlineDoctorSessionModel.fromJson(Map<String, dynamic> json) {
    final slotsList = json['slots'] as List;
    final slots = slotsList.map((s) => OnlineDoctorSlotModel.fromJson(s)).toList();
    return OnlineDoctorSessionModel(
      name: json['session'],
      icon: json['session_icon'],
      totalSlots: json['total_slots'],
      availableSlots: json['available_slots'],
      slots: slots,
    );
  }
}