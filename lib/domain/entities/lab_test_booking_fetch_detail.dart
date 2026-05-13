import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class LabTestBookingFetchDetail extends Equatable {
  final String bookingId;
  final String labTestName;
  final String labTestLogo;
  final String labTestAddress;
  final String patientName;
  final String patientMobile;
  final String patientDob;
  final String patientEmail;
  final String prescriptionUrl;
  final String bookingStatus;
  final String createdOn;
  final String? completedDate;

  const LabTestBookingFetchDetail({
    required this.bookingId,
    required this.labTestName,
    required this.labTestLogo,
    required this.labTestAddress,
    required this.patientName,
    required this.patientMobile,
    required this.patientDob,
    required this.patientEmail,
    required this.prescriptionUrl,
    required this.bookingStatus,
    required this.createdOn,
    this.completedDate,
  });

  @override
  List<Object?> get props => [bookingId];
}