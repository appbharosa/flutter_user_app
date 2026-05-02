import '../../domain/entities/pharmacy.dart';

class PharmacyModel extends Pharmacy {
  const PharmacyModel({
    required super.id,
    required super.name,
    super.openTime,
    super.closeTime,
    required super.logo,
    required super.homeDelivery,
    required super.location,
    required super.lat,
    required super.lon,
    required super.distance,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'],
      name: json['name'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      logo: json['logo'],
      homeDelivery: json['home_delivery'],
      location: json['location'],
      lat: json['lat'],
      lon: json['lon'],
      distance: json['distance'],
    );
  }
}