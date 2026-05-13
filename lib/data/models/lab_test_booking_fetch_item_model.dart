import '../../domain/entities/lab_test_booking_fetch_item.dart';

import '../../domain/entities/lab_test_booking_fetch_item.dart';

class LabTestBookingFetchItemModel extends LabTestBookingFetchItem {
  const LabTestBookingFetchItemModel({
    required super.bookingId,
    required super.name,
    required super.location,
    required super.logo,
    super.completedDate,
  });

  factory LabTestBookingFetchItemModel.fromJson(Map<String, dynamic> json, {bool isCompleted = false}) {
    return LabTestBookingFetchItemModel(
      bookingId: json['booking_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      logo: json['logo'] ?? '',
      completedDate: isCompleted ? json['completed_date'] : null,
    );
  }
}