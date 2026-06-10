import 'package:equatable/equatable.dart';

class PharmacyProduct extends Equatable {
  final int id;
  final String name;
  final String type;
  final String description;
  final String discountPrice;
  final String price;
  final String image;

  const PharmacyProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.discountPrice,
    required this.price,
    required this.image,
  });

  double get discountPercent {
    final original = double.tryParse(price) ?? 0;
    final discounted = double.tryParse(discountPrice) ?? 0;
    if (original == 0) return 0;
    return ((original - discounted) / original) * 100;
  }

  @override
  List<Object?> get props => [id, name];
}