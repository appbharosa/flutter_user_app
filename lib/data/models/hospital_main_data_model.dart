import '../../domain/entities/hospital_main_data.dart';

class HospitalMainDataModel extends HospitalMainData {
  const HospitalMainDataModel({
    required super.id,
    required super.name,
    required super.tagline,
    required super.logo,
    required super.openTime,
    required super.closeTime,
    required super.location,
    required super.lat,
    required super.lon,
    required super.description,
    required super.contactNumber,
    required super.email,
    required super.website,
  });

  factory HospitalMainDataModel.fromJson(Map<String, dynamic> json) {
    return HospitalMainDataModel(
      id: json['id'],
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      logo: json['logo'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      location: json['location'] ?? '',
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',
      description: json['description'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }
}