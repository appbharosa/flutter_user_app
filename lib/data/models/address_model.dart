import 'dart:convert';
import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.address,
    super.hno,
    super.buildingNo,
    super.landmark,
    required super.lat,
    required super.lon,
    required super.addressType,
    required super.pincode,
    required super.state,
    required super.city,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      hno: json['hno'],
      buildingNo: json['building_no'],
      landmark: json['landmark'],
      lat: json['lat']?.toString() ?? '0.0',
      lon: json['lon']?.toString() ?? '0.0',
      addressType: json['address_type'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      isDefault: json['default_address'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'hno': hno,
      'building_no': buildingNo,
      'landmark': landmark,
      'lat': lat,
      'lon': lon,
      'address_type': addressType,
      'pincode': pincode,
      'state': state,
      'city': city,
      'default_address': isDefault ? 1 : 0,
    };
  }

  // ✅ Convert from JSON string to Address object
  factory AddressModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return AddressModel.fromJson(jsonMap);
  }

  // ✅ Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}