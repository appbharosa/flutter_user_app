

import 'package:equatable/equatable.dart';

abstract class LabTestBookingEvent extends Equatable {
  const LabTestBookingEvent();
  @override List<Object> get props => [];
}

class BookLabTest extends LabTestBookingEvent {
  final int labTestId;
  final List<String> prescriptionPaths;
  final String lang;
  final int familyMemberId;
  const BookLabTest({
    required this.labTestId,
    required this.prescriptionPaths,
    required this.lang,
    required this.familyMemberId,
  });
}