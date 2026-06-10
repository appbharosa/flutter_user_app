import '../../domain/entities/pharmacy_product.dart';

class PharmacyProductModel extends PharmacyProduct {
  const PharmacyProductModel({
    required super.id,
    required super.name,
    required super.type,
    required super.description,
    required super.discountPrice,
    required super.price,
    required super.image,
  });

  factory PharmacyProductModel.fromJson(Map<String, dynamic> json) {
    return PharmacyProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountPrice: json['discount_price'] as String,
      price: json['price'] as String,
      image: json['image'] as String,
    );
  }
}