import 'dart:convert';
import 'package:equatable/equatable.dart';

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
    // Robust parsing for 'default_address' – handles int, bool, and string
    bool parseDefault(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final trimmed = value.trim().toLowerCase();
        return trimmed == '1' || trimmed == 'true';
      }
      return false;
    }

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
      isDefault: parseDefault(json['default_address']),
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

  // ✅ copyWith method – essential for client-side corrections
  Address copyWith({
    int? id,
    String? address,
    String? hno,
    String? buildingNo,
    String? landmark,
    String? lat,
    String? lon,
    String? addressType,
    String? pincode,
    String? state,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      address: address ?? this.address,
      hno: hno ?? this.hno,
      buildingNo: buildingNo ?? this.buildingNo,
      landmark: landmark ?? this.landmark,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      addressType: addressType ?? this.addressType,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    address,
    hno,
    buildingNo,
    landmark,
    lat,
    lon,
    addressType,
    pincode,
    state,
    city,
    isDefault,
  ];
}