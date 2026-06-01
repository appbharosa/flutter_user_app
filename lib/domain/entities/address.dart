import 'dart:convert';
import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final int id;
  final String address;
  final String? hno;
  final String? buildingNo;
  final String? landmark;
  final String lat;
  final String lon;
  final String addressType;
  final String pincode;
  final String state;
  final String city;
  final bool isDefault;

  const Address({
    required this.id,
    required this.address,
    this.hno,
    this.buildingNo,
    this.landmark,
    required this.lat,
    required this.lon,
    required this.addressType,
    required this.pincode,
    required this.state,
    required this.city,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
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

  // Convert from JSON string to Address object
  factory Address.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return Address.fromJson(jsonMap);
  }

  // Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [id, address, isDefault];
}