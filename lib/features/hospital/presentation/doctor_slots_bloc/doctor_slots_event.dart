
part of 'doctor_slots_bloc.dart';

abstract class DoctorSlotsEvent extends Equatable {
  const DoctorSlotsEvent();
  @override
  List<Object?> get props => [];
}

class LoadDoctorSlots extends DoctorSlotsEvent {
  final int doctorId;
  final String language;
  final String? date; // optional

  const LoadDoctorSlots({
    required this.doctorId,
    required this.language,
    this.date,
  });
}