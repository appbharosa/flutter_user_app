part of 'online_doctor_coupon_bloc.dart';

abstract class OnlineDoctorCouponState extends Equatable {
  const OnlineDoctorCouponState();
  @override List<Object> get props => [];
}

class OnlineDoctorCouponInitial extends OnlineDoctorCouponState {}
class OnlineDoctorCouponLoading extends OnlineDoctorCouponState {}
class OnlineDoctorCouponLoaded extends OnlineDoctorCouponState {
  final List<OnlineDoctorCoupon> coupons;
  OnlineDoctorCouponLoaded(this.coupons);
}
class OnlineDoctorCouponError extends OnlineDoctorCouponState {
  final String message;
  OnlineDoctorCouponError(this.message);
}