import '../../domain/entities/doctor_coupon.dart';

class DoctorCouponModel extends DoctorCoupon {
  DoctorCouponModel({
    required super.id,
    required super.name,
    required super.percentage,
    required super.description,
  });

  factory DoctorCouponModel.fromJson(Map<String, dynamic> json) {
    return DoctorCouponModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      percentage: json['percentage'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}