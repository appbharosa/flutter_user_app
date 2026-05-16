part of 'online_doctor_coupon_bloc.dart';

abstract class OnlineDoctorCouponEvent extends Equatable {
  const OnlineDoctorCouponEvent();
  @override List<Object> get props => [];
}

class LoadOnlineDoctorCoupons extends OnlineDoctorCouponEvent {
  final String lang;
  LoadOnlineDoctorCoupons(this.lang);
}