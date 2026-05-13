import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lab_coupon.dart';
import '../../domain/repositories/lab_coupon_repository.dart';
import '../data_sources/lab_coupon_remote_datasource.dart';

class LabCouponRepositoryImpl implements LabCouponRepository {
  final LabCouponRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  LabCouponRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<LabCoupon>>> getCoupons() async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final coupons = await remoteDataSource.getCoupons();
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