import '../../domain/entities/applied_coupon.dart';

class AppliedCouponModel extends AppliedCoupon {
  AppliedCouponModel({
    required super.code,
    required super.discountAmount,
    required super.finalAmount,
    required super.isValid,
  });

  factory AppliedCouponModel.fromJson(Map<String, dynamic> json) {
    return AppliedCouponModel(
      code: json['code'] ?? '',
      discountAmount: json['discount_amount'] ?? 0,
      finalAmount: json['final_amount'] ?? 0,
      isValid: json['is_valid'] ?? false,
    );
  }
}