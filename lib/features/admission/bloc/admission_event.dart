import 'package:equatable/equatable.dart';
import '../../../../domain/entities/admission_request.dart';

abstract class AdmissionEvent extends Equatable {
  const AdmissionEvent();
  @override
  List<Object?> get props => [];
}

class SubmitAdmissionEvent extends AdmissionEvent {
  final AdmissionRequest request;
  const SubmitAdmissionEvent(this.request);
  @override
  List<Object?> get props => [request];
}