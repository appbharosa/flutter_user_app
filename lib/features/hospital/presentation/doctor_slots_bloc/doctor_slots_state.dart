
part of 'doctor_slots_bloc.dart';

abstract class DoctorSlotsState extends Equatable {
  const DoctorSlotsState();
  @override
  List<Object?> get props => [];
}

class DoctorSlotsInitial extends DoctorSlotsState {}

class DoctorSlotsLoading extends DoctorSlotsState {}

class DoctorSlotsLoaded extends DoctorSlotsState {
  final DoctorSlotsResponse slots;
  const DoctorSlotsLoaded(this.slots);
  @override
  List<Object?> get props => [slots];
}

class DoctorSlotsError extends DoctorSlotsState {
  final String message;
  const DoctorSlotsError(this.message);
  @override
  List<Object?> get props => [message];
}