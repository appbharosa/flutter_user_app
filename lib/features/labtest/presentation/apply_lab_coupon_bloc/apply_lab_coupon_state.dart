

import 'package:equatable/equatable.dart';

abstract class ApplyLabCouponState extends Equatable {
  const ApplyLabCouponState();
  @override List<Object> get props => [];
}

class ApplyCouponInitial extends ApplyLabCouponState {}
class ApplyCouponLoading extends ApplyLabCouponState {}
class ApplyCouponSuccess extends ApplyLabCouponState {
  final String couponCode;
  final double discountAmount;
  final double finalAmount;
  const ApplyCouponSuccess({
    required this.couponCode,
    required this.discountAmount,
    required this.finalAmount,
  });
  @override List<Object> get props => [couponCode, discountAmount, finalAmount];
}
class ApplyCouponError extends ApplyLabCouponState {
  final String message;
  const ApplyCouponError(this.message);
}