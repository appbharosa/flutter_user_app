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
      code: json['code']?.toString() ?? '',
      discountAmount: _toInt(json['discount_amount']),
      finalAmount: _toInt(json['final_amount']),
      isValid: json['is_valid'] == true,
    );
  }

  // ✅ Safe conversion to int (handles double, string, null)
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}