
part of 'doctor_coupon_bloc.dart';

abstract class DoctorCouponEvent extends Equatable {
  const DoctorCouponEvent();
  @override
  List<Object?> get props => [];
}

class LoadDoctorCoupons extends DoctorCouponEvent {
  final String language;
  const LoadDoctorCoupons(this.language);
  @override
  List<Object?> get props => [language];
}

class ApplyDoctorCoupon extends DoctorCouponEvent {
  final String couponCode;
  final int subtotal;
  final String language;
  const ApplyDoctorCoupon({
    required this.couponCode,
    required this.subtotal,
    required this.language,
  });
  @override
  List<Object?> get props => [couponCode, subtotal, language];
}

class ResetAppliedCoupon extends DoctorCouponEvent {}