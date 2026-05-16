
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/online_doctor_speciality.dart';


abstract class OnlineDoctorSpecialityState extends Equatable {
  const OnlineDoctorSpecialityState();
  @override List<Object> get props => [];
}

class OnlineDoctorSpecialityInitial extends OnlineDoctorSpecialityState {}

class OnlineDoctorSpecialityLoading extends OnlineDoctorSpecialityState {}

class OnlineDoctorSpecialityLoaded extends OnlineDoctorSpecialityState {
  final List<OnlineDoctorSpeciality> specialities;
  const OnlineDoctorSpecialityLoaded(this.specialities);
  @override List<Object> get props => [specialities];
}

class OnlineDoctorSpecialityError extends OnlineDoctorSpecialityState {
  final String message;
  const OnlineDoctorSpecialityError(this.message);
  @override List<Object> get props => [message];
}