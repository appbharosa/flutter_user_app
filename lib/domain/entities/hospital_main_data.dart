import 'package:equatable/equatable.dart';
class HospitalMainData extends Equatable {
  final int id;
  final String name;
  final String tagline;
  final String logo;
  final String openTime;
  final String closeTime;
  final String location;
  final String lat;
  final String lon;
  final String description;
  final String contactNumber;
  final String email;
  final String website;

  const HospitalMainData({
    required this.id,
    required this.name,
    required this.tagline,
    required this.logo,
    required this.openTime,
    required this.closeTime,
    required this.location,
    required this.lat,
    required this.lon,
    required this.description,
    required this.contactNumber,
    required this.email,
    required this.website,
  });

  @override
  List<Object?> get props => [id, name];
}