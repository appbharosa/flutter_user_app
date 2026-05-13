import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_coupon.dart';

abstract class LabCouponRepository {
  Future<Either<Failure, List<LabCoupon>>> getCoupons();
  Future<Either<Failure, Map<String, dynamic>>> applyCoupon(String couponCode, double amount);
}