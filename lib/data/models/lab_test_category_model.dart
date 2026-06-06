import '../../domain/entities/lab_test_category.dart';

class LabTestCategoryModel extends LabTestCategory {
  const LabTestCategoryModel({
    required super.id,
    required super.name,
    required super.image,
  });

  factory LabTestCategoryModel.fromJson(Map<String, dynamic> json) {
    return LabTestCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}