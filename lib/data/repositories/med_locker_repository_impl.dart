import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/med_locker.dart';
import '../../domain/repositories/med_locker_repository.dart';
import '../data_sources/med_locker_remote_datasource.dart';


class MedLockerRepositoryImpl implements MedLockerRepository {
  final MedLockerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MedLockerRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<MedLocker>>> getMedLockers() async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final lockers = await remoteDataSource.getMedLockers();
      return Right(lockers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MedLocker>> getMedLockerDetail(int id) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final detail = await remoteDataSource.getMedLockerDetail(id);
      return Right(detail);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MedLocker>> addMedLocker({
    required String name,
    required List<String> imagePaths,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final files = imagePaths.map((path) => File(path)).toList();
      final added = await remoteDataSource.addMedLocker(name, files);
      return Right(added);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}