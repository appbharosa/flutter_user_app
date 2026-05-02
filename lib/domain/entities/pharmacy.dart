import 'package:equatable/equatable.dart';

class Pharmacy extends Equatable {
  final int id;
  final String name;
  final String? openTime;
  final String? closeTime;
  final String logo;
  final String homeDelivery;
  final String location;
  final String lat;
  final String lon;
  final String distance;

  const Pharmacy({
    required this.id,
    required this.name,
    this.openTime,
    this.closeTime,
    required this.logo,
    required this.homeDelivery,
    required this.location,
    required this.lat,
    required this.lon,
    required this.distance,
  });

  @override
  List<Object?> get props => [id, name];
}