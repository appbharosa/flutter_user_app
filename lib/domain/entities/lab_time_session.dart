import 'package:equatable/equatable.dart';
import 'package:user/domain/entities/lab_time_slot.dart';


class LabTimeSession extends Equatable {
  final String name;
  final String icon;
  final int totalSlots;
  final int availableSlots;
  final List<LabTimeSlot> slots;

  const LabTimeSession({
    required this.name,
    required this.icon,
    required this.totalSlots,
    required this.availableSlots,
    required this.slots,
  });

  @override
  List<Object?> get props => [name];
}