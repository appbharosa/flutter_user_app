import '../../domain/entities/online_doctor_coupon.dart';

class OnlineDoctorCouponModel extends OnlineDoctorCoupon {
  const OnlineDoctorCouponModel({
    required super.id,
    required super.name,
    required super.percentage,
    required super.description,
  });

  factory OnlineDoctorCouponModel.fromJson(Map<String, dynamic> json) {
    return OnlineDoctorCouponModel(
      id: json['id'],
      name: json['name'],
      percentage: json['percentage'],
      description: json['description'],
    );
  }
}