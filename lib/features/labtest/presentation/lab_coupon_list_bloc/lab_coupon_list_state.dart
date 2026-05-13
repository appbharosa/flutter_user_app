

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/lab_coupon.dart';

abstract class LabCouponListState extends Equatable {
  const LabCouponListState();
  @override List<Object> get props => [];
}

class LabCouponListInitial extends LabCouponListState {}
class LabCouponListLoading extends LabCouponListState {}
class LabCouponListLoaded extends LabCouponListState {
  final List<LabCoupon> coupons;
  const LabCouponListLoaded(this.coupons);
}
class LabCouponListError extends LabCouponListState {
  final String message;
  const LabCouponListError(this.message);
}