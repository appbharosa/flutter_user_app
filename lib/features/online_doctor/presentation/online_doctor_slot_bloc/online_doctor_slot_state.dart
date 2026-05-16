part of 'online_doctor_slot_bloc.dart';

abstract class OnlineDoctorSlotState extends Equatable {
  const OnlineDoctorSlotState();
  @override List<Object> get props => [];
}

class OnlineDoctorSlotInitial extends OnlineDoctorSlotState {}
class OnlineDoctorSlotLoading extends OnlineDoctorSlotState {}
class OnlineDoctorSlotLoaded extends OnlineDoctorSlotState {
  final OnlineDoctorSlotsResponse slots;
  OnlineDoctorSlotLoaded(this.slots);
}
class OnlineDoctorSlotError extends OnlineDoctorSlotState {
  final String message;
  OnlineDoctorSlotError(this.message);
}