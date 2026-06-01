// lib/features/free_lab/domain/entities/free_lab_package.dart
class FreeLabPackage {
  final int id;
  final String name;
  final String image;
  final String price;
  final String discountPrice;
  final String reportIn;
  final String fasting;
  final String suitableFor;
  final List<PackageTest> packageTests;

  FreeLabPackage({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.discountPrice,
    required this.reportIn,
    required this.fasting,
    required this.suitableFor,
    required this.packageTests,
  });
}

class PackageTest {
  final int testId;
  final int packageId;
  final String name;
  final List<TestParameter> parameters;

  PackageTest({
    required this.testId,
    required this.packageId,
    required this.name,
    required this.parameters,
  });
}

class TestParameter {
  final int id;
  final int testId;
  final String name;

  TestParameter({
    required this.id,
    required this.testId,
    required this.name,
  });
}