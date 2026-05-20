part of 'doctor_coupon_bloc.dart';

abstract class DoctorCouponState extends Equatable {
  const DoctorCouponState();
  @override
  List<Object?> get props => [];
}

class DoctorCouponInitial extends DoctorCouponState {}

class DoctorCouponLoading extends DoctorCouponState {}

class DoctorCouponLoaded extends DoctorCouponState {
  final List<DoctorCoupon> coupons;
  const DoctorCouponLoaded(this.coupons);
  @override
  List<Object?> get props => [coupons];
}

class DoctorCouponApplying extends DoctorCouponState {}

class DoctorCouponApplied extends DoctorCouponState {
  final AppliedCoupon applied;
  const DoctorCouponApplied(this.applied);
  @override
  List<Object?> get props => [applied];
}

class DoctorCouponError extends DoctorCouponState {
  final String message;
  const DoctorCouponError(this.message);
}

class DoctorCouponApplyError extends DoctorCouponState {
  final String message;
  const DoctorCouponApplyError(this.message);
}