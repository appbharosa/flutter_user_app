import '../../domain/entities/lab_test.dart';

import '../../domain/entities/lab_test.dart';
import '../../domain/entities/lab_test_package.dart';
import 'lab_test_package_model.dart';

class LabTestModel extends LabTest {
  const LabTestModel({
    required super.id,
    required super.name,
    required super.openTime,
    required super.closeTime,
    required super.logo,
    required super.location,
    required super.lat,
    required super.lon,
    required super.distance,
    required super.packages,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    final packagesList = (json['packages'] as List?) ?? [];
    final packages = packagesList.map((p) => LabTestPackageModel.fromJson(p)).toList();
    return LabTestModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      logo: json['logo'] ?? '',
      location: json['location'] ?? '',
      lat: json['lat']?.toString() ?? '0.0',
      lon: json['lon']?.toString() ?? '0.0',
      distance: json['distance'] ?? '0',
      packages: packages,
    );
  }
}