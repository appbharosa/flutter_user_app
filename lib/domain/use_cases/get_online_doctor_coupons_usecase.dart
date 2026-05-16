import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor_coupon.dart';
import '../repositories/online_doctor_coupon_repository.dart';

class GetOnlineDoctorCouponsUseCase {
  final OnlineDoctorCouponRepository repository;
  GetOnlineDoctorCouponsUseCase(this.repository);
  Future<Either<Failure, List<OnlineDoctorCoupon>>> call(String lang) async {
    return await repository.getCoupons(lang);
  }
}