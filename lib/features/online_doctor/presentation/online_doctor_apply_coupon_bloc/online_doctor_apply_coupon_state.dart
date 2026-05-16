part of 'online_doctor_apply_coupon_bloc.dart';

abstract class OnlineDoctorApplyCouponState extends Equatable {
  const OnlineDoctorApplyCouponState();
  @override List<Object> get props => [];
}

class OnlineDoctorApplyCouponInitial extends OnlineDoctorApplyCouponState {}
class OnlineDoctorApplyCouponLoading extends OnlineDoctorApplyCouponState {}
class OnlineDoctorApplyCouponSuccess extends OnlineDoctorApplyCouponState {
  final String couponCode;
  final double discountAmount;
  final double finalAmount;
  OnlineDoctorApplyCouponSuccess({required this.couponCode, required this.discountAmount, required this.finalAmount});
}
class OnlineDoctorApplyCouponError extends OnlineDoctorApplyCouponState {
  final String message;
  OnlineDoctorApplyCouponError(this.message);
}