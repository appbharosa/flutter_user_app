import '../../domain/entities/medicine_booking_response.dart';

class MedicineBookingResponseModel extends MedicineBookingResponse {
  const MedicineBookingResponseModel({
    required super.success,
    required super.message,
    super.bookingId,
  });

  factory MedicineBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return MedicineBookingResponseModel(
      success: json['status'] == 200,
      message: json['message'] ?? '',
      bookingId: result?['booking_id'],
    );
  }
}