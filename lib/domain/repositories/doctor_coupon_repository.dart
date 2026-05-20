
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_coupon.dart';
import '../entities/applied_coupon.dart';

abstract class DoctorCouponRepository {
  Future<Either<Failure, List<DoctorCoupon>>> getCoupons(String language);
  Future<Either<Failure, AppliedCoupon>> applyCoupon({
    required String couponCode,
    required int subtotal,
    required String language,
  });
}