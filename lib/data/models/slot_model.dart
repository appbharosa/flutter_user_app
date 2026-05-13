

import 'package:user/domain/entities/lab_time_slot.dart';

class SlotModel extends LabTimeSlot {
  const SlotModel({
    required super.slotId,
    required super.time,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    required super.isBooked,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      slotId: json['slot_id'],
      time: json['time'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isAvailable: json['is_available'],
      isBooked: json['is_booked'],
    );
  }
}