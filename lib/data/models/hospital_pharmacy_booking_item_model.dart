
import '../../domain/entities/hospital_pharmacy_booking_item.dart';

class HospitalPharmacyBookingItemModel extends HospitalPharmacyBookingItem {
  HospitalPharmacyBookingItemModel({
    required super.id,
    required super.bookingId,
    required super.orderType,
    required super.createdOn,
    required super.bookingType,
    required super.bookingStatus,
    required super.image,
    required super.acceptStatus,
    required super.logo,
    required super.location,
    required super.hospitalName,
  });

  factory HospitalPharmacyBookingItemModel.fromJson(Map<String, dynamic> json) {
    return HospitalPharmacyBookingItemModel(
      id: _toInt(json['id']),
      bookingId: _toString(json['booking_id']),
      orderType: _toString(json['order_type']),
      createdOn: _toString(json['created_on']),
      bookingType: _toString(json['booking_type']),
      bookingStatus: _toString(json['booking_status']),
      image: _toString(json['image']),
      acceptStatus: _toString(json['accept_status']),
      logo: _toString(json['logo']),
      location: _toString(json['location']),
      hospitalName: _toString(json['hospital_name']),
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