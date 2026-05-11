import '../../domain/entities/booking_response.dart';

class BookingResponseModel extends BookingResponse {
  const BookingResponseModel(super.bookingId);

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final result = json['result'];
      final bookingId = result is Map ? result['booking_id']?.toString() : null;
      return BookingResponseModel(bookingId ?? '');
    } catch (e) {
      print("❌ Error parsing BookingResponseModel: $e");
      return const BookingResponseModel('');
    }
  }
}