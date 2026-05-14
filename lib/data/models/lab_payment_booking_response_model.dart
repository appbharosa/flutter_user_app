import '../../domain/entities/lab_payment_booking_response.dart';


import '../../core/utils/parsers.dart';

class LabPaymentBookingResponseModel extends LabPaymentBookingResponse {
  const LabPaymentBookingResponseModel({
    required super.bookingId,
    required super.bookingStatus,
    required super.paymentStatus,
  });

  factory LabPaymentBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return LabPaymentBookingResponseModel(
      bookingId: safeParseInt(result['booking_id']),
      bookingStatus: result['booking_status'] ?? '',
      paymentStatus: result['payment_status'] ?? '',
    );
  }
}