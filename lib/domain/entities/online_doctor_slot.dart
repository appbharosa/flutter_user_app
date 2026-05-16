import 'package:equatable/equatable.dart';

class OnlineDoctorSlot extends Equatable {
  final int slotId;
  final String time;
  final String startTime;
  final bool isAvailable;
  final bool isBooked;

  const OnlineDoctorSlot({
    required this.slotId,
    required this.time,
    required this.startTime,
    required this.isAvailable,
    required this.isBooked,
  });

  @override
  List<Object?> get props => [slotId, time];
}