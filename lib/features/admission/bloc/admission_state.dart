// lib/presentation/admission/bloc/admission_state.dart
import 'package:equatable/equatable.dart';

abstract class AdmissionState extends Equatable {
  const AdmissionState();
  @override
  List<Object?> get props => [];
}

class AdmissionInitial extends AdmissionState {}

class AdmissionLoading extends AdmissionState {}

class AdmissionSuccess extends AdmissionState {}

class AdmissionError extends AdmissionState {
  final String message;
  const AdmissionError(this.message);
  @override
  List<Object?> get props => [message];
}