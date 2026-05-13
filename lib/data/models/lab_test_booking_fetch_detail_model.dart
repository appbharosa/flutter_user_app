import '../../domain/entities/lab_test_booking_fetch_detail.dart';


class LabTestBookingFetchDetailModel extends LabTestBookingFetchDetail {
  const LabTestBookingFetchDetailModel({
    required super.bookingId,
    required super.labTestName,
    required super.labTestLogo,
    required super.labTestAddress,
    required super.patientName,
    required super.patientMobile,
    required super.patientDob,
    required super.patientEmail,
    required super.prescriptionUrl,
    required super.bookingStatus,
    required super.createdOn,
    super.completedDate,
  });

  factory LabTestBookingFetchDetailModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return LabTestBookingFetchDetailModel(
      bookingId: result['booking_id'] ?? '',
      labTestName: result['lab_test_name'] ?? '',
      labTestLogo: result['lab_test_logo'] ?? '',
      labTestAddress: result['lab_test_address'] ?? '',
      patientName: result['name'] ?? '',
      patientMobile: result['mobile']?.toString() ?? '',
      patientDob: result['dob'] ?? '',
      patientEmail: result['email'] ?? '',
      prescriptionUrl: result['presciption'] ?? '',
      bookingStatus: result['booking_status'] ?? '',
      createdOn: result['created_on'] ?? '',
      completedDate: result['completed_date'],
    );
  }
}