import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/online_doctor_coupon.dart';
import '../../domain/repositories/online_doctor_coupon_repository.dart';
import '../data_sources/online_doctor_coupon_remote_datasource.dart';


class OnlineDoctorCouponRepositoryImpl implements OnlineDoctorCouponRepository {
  final OnlineDoctorCouponRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  OnlineDoctorCouponRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<OnlineDoctorCoupon>>> getCoupons(String lang) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final coupons = await remoteDataSource.getCoupons(lang);
      return Right(coupons);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> applyCoupon(String couponCode, double amount) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final result = await remoteDataSource.applyCoupon(couponCode, amount);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}