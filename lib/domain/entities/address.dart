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

  @override
  List<Object?> get props => [id, address, isDefault];
}