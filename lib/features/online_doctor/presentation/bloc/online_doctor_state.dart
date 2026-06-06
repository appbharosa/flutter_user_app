

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/online_doctor.dart';

import 'package:equatable/equatable.dart';
import '../../../../domain/entities/online_doctor.dart';

abstract class OnlineDoctorState extends Equatable {
  const OnlineDoctorState();
  @override
  List<Object> get props => [];
}

class OnlineDoctorInitial extends OnlineDoctorState {}

class OnlineDoctorLoading extends OnlineDoctorState {}

class OnlineDoctorLoaded extends OnlineDoctorState {
  final List<OnlineDoctor> doctors;
  final bool hasMore;
  final int? selectedSpecialityId;

  const OnlineDoctorLoaded(this.doctors, this.hasMore, this.selectedSpecialityId);

  @override
  List<Object> get props => [doctors, hasMore, selectedSpecialityId ?? -1];
}

class OnlineDoctorError extends OnlineDoctorState {
  final String message;
  const OnlineDoctorError(this.message);
  @override
  List<Object> get props => [message];
}