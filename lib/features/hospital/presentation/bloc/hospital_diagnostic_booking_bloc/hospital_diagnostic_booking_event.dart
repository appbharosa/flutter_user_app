
import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/hospital_diagnostic_booking.dart';

abstract class HospitalDiagnosticBookingEvent extends Equatable {
  const HospitalDiagnosticBookingEvent();
  @override
  List<Object?> get props => [];
}

class SubmitHospitalDiagnosticEvent extends HospitalDiagnosticBookingEvent {
  final HospitalDiagnosticBooking booking;
  const SubmitHospitalDiagnosticEvent(this.booking);
  @override
  List<Object?> get props => [booking];
}

class ResetHospitalDiagnosticEvent extends HospitalDiagnosticBookingEvent {}