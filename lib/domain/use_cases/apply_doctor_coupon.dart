
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/applied_coupon.dart';
import '../repositories/doctor_coupon_repository.dart';

class ApplyDoctorCouponUseCase {
  final DoctorCouponRepository repository;
  ApplyDoctorCouponUseCase(this.repository);

  Future<Either<Failure, AppliedCoupon>> call({
    required String couponCode,
    required int subtotal,
    required String language,
  }) async {
    return await repository.applyCoupon(
      couponCode: couponCode,
      subtotal: subtotal,
      language: language,
    );
  }
}