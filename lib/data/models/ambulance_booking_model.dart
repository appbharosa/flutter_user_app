

import '../../domain/entities/ambulance_booking.dart';

class AmbulanceBookingModel extends AmbulanceBooking {
  AmbulanceBookingModel({
    required super.bookingId,
    required super.message,
  });

  factory AmbulanceBookingModel.fromJson(Map<String, dynamic> json) {
    return AmbulanceBookingModel(
      bookingId: json['result']['booking_id'] ?? '',
      message: json['message'] ?? '',
    );
  }
}