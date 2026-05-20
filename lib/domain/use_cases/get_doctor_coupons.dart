
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_coupon.dart';
import '../repositories/doctor_coupon_repository.dart';

class GetDoctorCouponsUseCase {
  final DoctorCouponRepository repository;
  GetDoctorCouponsUseCase(this.repository);

  Future<Either<Failure, List<DoctorCoupon>>> call(String language) async {
    return await repository.getCoupons(language);
  }
}