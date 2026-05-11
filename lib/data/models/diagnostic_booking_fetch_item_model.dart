import '../../domain/entities/diagnostic_booking_fetch_item.dart';


class DiagnosticBookingFetchItemModel extends DiagnosticBookingFetchItem {
  const DiagnosticBookingFetchItemModel({
    required super.bookingId,
    required super.name,
    required super.location,
    required super.logo,
  });

  factory DiagnosticBookingFetchItemModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticBookingFetchItemModel(
      bookingId: json['booking_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}