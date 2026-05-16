import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor_coupon.dart';

abstract class OnlineDoctorCouponRepository {
  Future<Either<Failure, List<OnlineDoctorCoupon>>> getCoupons(String lang);
  Future<Either<Failure, Map<String, dynamic>>> applyCoupon(String couponCode, double amount);
}