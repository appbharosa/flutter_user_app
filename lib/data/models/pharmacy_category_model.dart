import '../../domain/entities/pharmacy_category.dart';

class PharmacyCategoryModel extends PharmacyCategory {
  const PharmacyCategoryModel({
    required super.id,
    required super.name,
    required super.image,
  });

  factory PharmacyCategoryModel.fromJson(Map<String, dynamic> json) {
    return PharmacyCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}