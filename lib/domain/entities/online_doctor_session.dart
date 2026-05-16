import 'package:equatable/equatable.dart';
import 'online_doctor_slot.dart';

class OnlineDoctorSession extends Equatable {
  final String name;
  final String icon;
  final int totalSlots;
  final int availableSlots;
  final List<OnlineDoctorSlot> slots;

  const OnlineDoctorSession({
    required this.name,
    required this.icon,
    required this.totalSlots,
    required this.availableSlots,
    required this.slots,
  });

  @override
  List<Object?> get props => [name];
}