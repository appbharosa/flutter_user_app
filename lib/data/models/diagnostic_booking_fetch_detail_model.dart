import '../../domain/entities/diagnostic_booking_fetch_detail.dart';


class DiagnosticBookingFetchDetailModel extends DiagnosticBookingFetchDetail {
  const DiagnosticBookingFetchDetailModel({
    required super.bookingId,
    required super.diagnosticsName,
    required super.diagnosticsLogo,
    required super.diagnosticsAddress,
    required super.patientName,
    required super.patientMobile,
    required super.patientDob,
    required super.patientEmail,
    required super.prescriptionUrl,
    required super.bookingStatus,
    required super.createdOn,
  });

  factory DiagnosticBookingFetchDetailModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return DiagnosticBookingFetchDetailModel(
      bookingId: result['booking_id'] ?? '',
      diagnosticsName: result['diagnostics_name'] ?? '',
      diagnosticsLogo: result['diagnostics_logo'] ?? '',
      diagnosticsAddress: result['diagnostics_address'] ?? '',
      patientName: result['name'] ?? '',
      patientMobile: result['mobile']?.toString() ?? '',
      patientDob: result['dob'] ?? '',
      patientEmail: result['email'] ?? '',
      prescriptionUrl: result['presciption'] ?? '',
      bookingStatus: result['booking_status'] ?? '',
      createdOn: result['created_on'] ?? '',
    );
  }
}