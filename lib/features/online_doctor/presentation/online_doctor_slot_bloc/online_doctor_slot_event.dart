part of 'online_doctor_slot_bloc.dart';

abstract class OnlineDoctorSlotEvent extends Equatable {
  const OnlineDoctorSlotEvent();
  @override List<Object> get props => [];
}

class LoadOnlineDoctorSlots extends OnlineDoctorSlotEvent {
  final String date;
  LoadOnlineDoctorSlots(this.date);
}