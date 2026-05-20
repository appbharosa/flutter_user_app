
import 'package:equatable/equatable.dart';

abstract class OnlineDoctorBookingState extends Equatable {
  const OnlineDoctorBookingState();
  @override
  List<Object?> get props => [];
}

class OnlineDoctorBookingInitial extends OnlineDoctorBookingState {}

class OnlineDoctorBookingLoading extends OnlineDoctorBookingState {}

class OnlineDoctorBookingSuccess extends OnlineDoctorBookingState {
  final String message;
  const OnlineDoctorBookingSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class OnlineDoctorBookingFailure extends OnlineDoctorBookingState {
  final String error;
  const OnlineDoctorBookingFailure(this.error);
  @override
  List<Object?> get props => [error];
}