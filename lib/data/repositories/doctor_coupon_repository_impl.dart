
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/doctor_coupon.dart';
import '../../domain/entities/applied_coupon.dart';
import '../../domain/repositories/doctor_coupon_repository.dart';
import '../data_sources/doctor_coupon_remote_datasource.dart';

class DoctorCouponRepositoryImpl implements DoctorCouponRepository {
  final DoctorCouponRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DoctorCouponRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DoctorCoupon>>> getCoupons(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final coupons = await remoteDataSource.getCoupons(language);
      return Right(coupons);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AppliedCoupon>> applyCoupon({
    required String couponCode,
    required int subtotal,
    required String language,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final applied = await remoteDataSource.applyCoupon(
        couponCode: couponCode,
        subtotal: subtotal,
        language: language,
      );
      return Right(applied);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}