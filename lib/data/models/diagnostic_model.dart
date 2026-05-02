import '../../domain/entities/diagnostic.dart';

class DiagnosticModel extends Diagnostic {
  const DiagnosticModel({
    required super.id,
    required super.name,
    required super.openTime,
    required super.closeTime,
    required super.logo,
    required super.location,
    required super.lat,
    required super.lon,
    required super.distance,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      logo: json['logo'] ?? '',
      location: json['location'] ?? '',
      lat: json['lat']?.toString() ?? '0.0',
      lon: json['lon']?.toString() ?? '0.0',
      distance: json['distance'] ?? '0',
    );
  }
}