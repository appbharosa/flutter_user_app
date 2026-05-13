import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/lab_coupon_repository.dart';

class ApplyLabCouponParams {
  final String couponCode;
  final double amount;
  ApplyLabCouponParams({required this.couponCode, required this.amount});
}

class ApplyLabCouponUseCase {
  final LabCouponRepository repository;
  ApplyLabCouponUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call(ApplyLabCouponParams params) async {
    return await repository.applyCoupon(params.couponCode, params.amount);
  }
}