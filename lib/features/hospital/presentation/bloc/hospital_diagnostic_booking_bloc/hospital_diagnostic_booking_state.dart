

import 'package:equatable/equatable.dart';

abstract class HospitalDiagnosticBookingState extends Equatable {
  const HospitalDiagnosticBookingState();
  @override
  List<Object?> get props => [];
}

class HospitalDiagnosticInitial extends HospitalDiagnosticBookingState {}

class HospitalDiagnosticLoading extends HospitalDiagnosticBookingState {}

class HospitalDiagnosticSuccess extends HospitalDiagnosticBookingState {
  final String message;
  const HospitalDiagnosticSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class HospitalDiagnosticFailure extends HospitalDiagnosticBookingState {
  final String error;
  const HospitalDiagnosticFailure(this.error);
  @override
  List<Object?> get props => [error];
}