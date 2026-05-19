
import '../../domain/entities/hospital_diagnostic_booking_item.dart';

class HospitalDiagnosticBookingItemModel extends HospitalDiagnosticBookingItem {
  HospitalDiagnosticBookingItemModel({
    required super.id,
    required super.bookingId,
    required super.createdOn,
    required super.userId,
    required super.diagnosticId,
    required super.name,
    required super.logo,
    required super.openTime,
    required super.closeTime,
    required super.location,
    required super.slotId,
    required super.date,
    required super.time,
    required super.bookingStatus,
    required super.bookingType,
    required super.packages,
  });

  factory HospitalDiagnosticBookingItemModel.fromJson(Map<String, dynamic> json) {
    return HospitalDiagnosticBookingItemModel(
      id: _toInt(json['id']),
      bookingId: _toString(json['booking_id']),
      createdOn: _toString(json['created_on']),
      userId: _toInt(json['user_id']),
      diagnosticId: _toInt(json['diagnostic_id']),
      name: _toString(json['name']),
      logo: _toString(json['logo']),
      openTime: _toString(json['open_time']),
      closeTime: _toString(json['close_time']),
      location: _toString(json['location']),
      slotId: _toInt(json['slot_id']),
      date: _toString(json['date']),
      time: _toString(json['time']),
      bookingStatus: _toString(json['booking_status']),
      bookingType: _toString(json['booking_type']),
      packages: json['packages'] is Map ? Map<String, dynamic>.from(json['packages']) : {},
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}