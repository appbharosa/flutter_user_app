
import '../../domain/entities/pharmacy_booking_item.dart';

class PharmacyBookingItemModel extends PharmacyBookingItem {
  PharmacyBookingItemModel({
    required super.id,
    required super.bookingId,
    required super.hospitalName,
    required super.orderType,
    required super.createdOn,
    required super.bookingType,
    required super.bookingStatus,
    required super.image,
    required super.acceptStatus,
    required super.products,
  });

  factory PharmacyBookingItemModel.fromJson(Map<String, dynamic> json) {
    return PharmacyBookingItemModel(
      id: _toInt(json['id']),
      bookingId: _toString(json['booking_id']),
      hospitalName: _toString(json['hospital_name']),
      orderType: _toString(json['order_type']),
      createdOn: _toString(json['created_on']),
      bookingType: _toString(json['booking_type']),
      bookingStatus: _toString(json['booking_status']),
      image: _toString(json['image']),
      acceptStatus: _toString(json['accept_status']),
      products: json['products'] is List ? json['products'] : [],
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