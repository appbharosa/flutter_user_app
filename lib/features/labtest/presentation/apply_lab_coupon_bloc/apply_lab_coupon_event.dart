

import 'package:equatable/equatable.dart';

abstract class ApplyLabCouponEvent extends Equatable {
  const ApplyLabCouponEvent();
  @override List<Object> get props => [];
}

class ApplyCoupon extends ApplyLabCouponEvent {
  final String couponCode;
  final double amount;
  const ApplyCoupon(this.couponCode, this.amount);
}