import 'package:equatable/equatable.dart';

class DiagnosticBookingFetchDetail extends Equatable {
  final String bookingId;
  final String diagnosticsName;
  final String diagnosticsLogo;
  final String diagnosticsAddress;
  final String patientName;
  final String patientMobile;
  final String patientDob;
  final String patientEmail;
  final String prescriptionUrl;
  final String bookingStatus;
  final String createdOn;

  const DiagnosticBookingFetchDetail({
    required this.bookingId,
    required this.diagnosticsName,
    required this.diagnosticsLogo,
    required this.diagnosticsAddress,
    required this.patientName,
    required this.patientMobile,
    required this.patientDob,
    required this.patientEmail,
    required this.prescriptionUrl,
    required this.bookingStatus,
    required this.createdOn,
  });

  @override
  List<Object?> get props => [bookingId];
}