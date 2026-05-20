
class AppliedCoupon {
  final String code;
  final int discountAmount;
  final int finalAmount;
  final bool isValid;

  AppliedCoupon({
    required this.code,
    required this.discountAmount,
    required this.finalAmount,
    required this.isValid,
  });
}