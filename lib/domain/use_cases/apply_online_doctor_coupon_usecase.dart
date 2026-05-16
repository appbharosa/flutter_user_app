import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/online_doctor_coupon_repository.dart';

class ApplyOnlineDoctorCouponParams {
  final String couponCode;
  final double amount;
  ApplyOnlineDoctorCouponParams(this.couponCode, this.amount);
}

class ApplyOnlineDoctorCouponUseCase {
  final OnlineDoctorCouponRepository repository;
  ApplyOnlineDoctorCouponUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call(ApplyOnlineDoctorCouponParams params) async {
    return await repository.applyCoupon(params.couponCode, params.amount);
  }
}