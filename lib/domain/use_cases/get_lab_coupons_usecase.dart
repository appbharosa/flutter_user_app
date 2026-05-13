import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_coupon.dart';
import '../repositories/lab_coupon_repository.dart';

class GetLabCouponsUseCase {
  final LabCouponRepository repository;
  GetLabCouponsUseCase(this.repository);
  Future<Either<Failure, List<LabCoupon>>> call() async {
    return await repository.getCoupons();
  }
}