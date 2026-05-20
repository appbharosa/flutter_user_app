
import 'package:equatable/equatable.dart';

abstract class DoctorBookingState extends Equatable {
  const DoctorBookingState();
  @override
  List<Object?> get props => [];
}

class DoctorBookingInitial extends DoctorBookingState {}

class DoctorBookingLoading extends DoctorBookingState {}

class DoctorBookingSuccess extends DoctorBookingState {
  final String message;
  const DoctorBookingSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DoctorBookingFailure extends DoctorBookingState {
  final String error;
  const DoctorBookingFailure(this.error);
  @override
  List<Object?> get props => [error];
}