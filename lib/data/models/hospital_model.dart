import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.openTime,
    required super.closeTime,
    required super.logo,
    required super.tagline,
    required super.location,
    required super.lat,
    required super.lon,
    required super.distance,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      logo: json['logo'] ?? '',
      tagline: json['tagline'] ?? '',
      location: json['location'] ?? '',
      lat: json['lat']?.toString() ?? '0.0',
      lon: json['lon']?.toString() ?? '0.0',
      distance: json['distance'] ?? '0',
    );
  }
}