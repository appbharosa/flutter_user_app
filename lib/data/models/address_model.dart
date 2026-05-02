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
      id: json['id'],
      address: json['address'],
      hno: json['hno'],
      buildingNo: json['building_no'],
      landmark: json['landmark'],
      lat: json['lat'].toString(),
      lon: json['lon'].toString(),
      addressType: json['address_type'],
      pincode: json['pincode'].toString(),
      state: json['state'],
      city: json['city'],
      isDefault: json['default_address'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}