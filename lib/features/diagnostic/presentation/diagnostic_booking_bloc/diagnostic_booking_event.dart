

import 'package:equatable/equatable.dart';

abstract class DiagnosticBookingEvent extends Equatable {
  const DiagnosticBookingEvent();
  @override List<Object> get props => [];
}

class BookDiagnosticEvent extends DiagnosticBookingEvent {
  final int diagnosticId;
  final List<String> prescriptionPaths;
  final String lang;
  final int familyMemberId;
  const BookDiagnosticEvent({required this.diagnosticId, required this.prescriptionPaths, required this.lang, required this.familyMemberId});
}