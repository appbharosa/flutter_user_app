import '../../domain/entities/lab_coupon.dart';

class LabCouponModel extends LabCoupon {
  const LabCouponModel({
    required super.id,
    required super.name,
    required super.percentage,
    required super.description,
  });

  factory LabCouponModel.fromJson(Map<String, dynamic> json) {
    return LabCouponModel(
      id: json['id'],
      name: json['name'],
      percentage: json['percentage'],
      description: json['description'],
    );
  }
}