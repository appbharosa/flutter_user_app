import 'package:equatable/equatable.dart';

class LabTest extends Equatable {
  final int id;
  final String name;
  final String openTime;
  final String closeTime;
  final String logo;
  final String location;
  final String lat;
  final String lon;
  final String distance;

  const LabTest({
    required this.id,
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.logo,
    required this.location,
    required this.lat,
    required this.lon,
    required this.distance,
  });

  @override
  List<Object?> get props => [id, name];
}