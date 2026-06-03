import '../../domain/entities/free_lab_package.dart';

class FreeLabPackageModel extends FreeLabPackage {
  FreeLabPackageModel({
    required super.id,
    required super.name,
    required super.image,
    required super.price,
    required super.discountPrice,
    required super.reportIn,
    required super.fasting,
    required super.suitableFor,
    required super.packageTests,
  });

  factory FreeLabPackageModel.fromJson(Map<String, dynamic> json) {
    final packageTestsList = json['package_tests'] as List? ?? [];
    return FreeLabPackageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? '0',
      discountPrice: json['discount_price'] ?? '0',
      reportIn: json['report_in'] ?? '',
      fasting: json['fasting'] ?? '',
      suitableFor: json['suitable_for'] ?? '',
      packageTests: packageTestsList.map((test) => PackageTestModel.fromJson(test)).toList(),
    );
  }
}

class PackageTestModel extends PackageTest {
  PackageTestModel({
    required super.testId,
    required super.packageId,
    required super.name,
    required super.parameters,
  });

  factory PackageTestModel.fromJson(Map<String, dynamic> json) {
    final parametersList = json['parameters'] as List? ?? [];
    return PackageTestModel(
      testId: json['test_id'] ?? 0,
      packageId: json['package_id'] ?? 0,
      name: json['name'] ?? '',
      parameters: parametersList.map((param) => TestParameterModel.fromJson(param)).toList(),
    );
  }
}

class TestParameterModel extends TestParameter {
  TestParameterModel({
    required super.id,
    required super.testId,
    required super.name,
  });

  factory TestParameterModel.fromJson(Map<String, dynamic> json) {
    return TestParameterModel(
      id: json['id'] ?? 0,
      testId: json['test_id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}