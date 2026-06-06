import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/free_lab_package.dart';
import '../../domain/entities/free_lab_slot.dart';
import '../../domain/repositories/free_lab_repository.dart';
import '../data_sources/free_lab_remote_datasource.dart';

class FreeLabRepositoryImpl implements FreeLabRepository {
  final FreeLabRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FreeLabRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FreeLabPackage>>> getFreeLabPackages(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final packages = await remoteDataSource.getFreeLabPackages(language);
      return Right(packages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, FreeLabSlotResponse>> getFreeLabSlots(String language, int packageId) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final slots = await remoteDataSource.getFreeLabSlots(language, packageId);
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FreeLabPackage>>> getPackagesByCategoryId({
    required int categoryId,
    required String language,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final packages = await remoteDataSource.getPackagesByCategoryId(
        categoryId: categoryId,
        language: language,
      );
      return Right(packages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}