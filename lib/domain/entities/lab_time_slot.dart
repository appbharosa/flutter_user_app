import 'package:equatable/equatable.dart';

class LabTimeSlot extends Equatable {
  final int slotId;
  final String time;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final bool isBooked;

  const LabTimeSlot({
    required this.slotId,
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.isBooked,
  });

  @override
  List<Object?> get props => [slotId];
}