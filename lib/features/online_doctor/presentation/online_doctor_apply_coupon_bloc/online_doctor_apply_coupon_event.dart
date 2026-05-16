part of 'online_doctor_apply_coupon_bloc.dart';

abstract class OnlineDoctorApplyCouponEvent extends Equatable {
  const OnlineDoctorApplyCouponEvent();
  @override List<Object> get props => [];
}

class ApplyOnlineDoctorCoupon extends OnlineDoctorApplyCouponEvent {
  final String couponCode;
  final double amount;
  ApplyOnlineDoctorCoupon(this.couponCode, this.amount);
}