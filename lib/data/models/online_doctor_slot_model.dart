import '../../domain/entities/online_doctor_slot.dart';

class OnlineDoctorSlotModel extends OnlineDoctorSlot {
  const OnlineDoctorSlotModel({
    required super.slotId,
    required super.time,
    required super.startTime,
    required super.isAvailable,
    required super.isBooked,
  });

  factory OnlineDoctorSlotModel.fromJson(Map<String, dynamic> json) {
    return OnlineDoctorSlotModel(
      slotId: json['slot_id'],
      time: json['time'],
      startTime: json['start_time'],
      isAvailable: json['is_available'],
      isBooked: json['is_booked'],
    );
  }
}