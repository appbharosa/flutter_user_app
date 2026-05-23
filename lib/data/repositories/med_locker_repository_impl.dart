import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/med_locker.dart';
import '../../domain/entities/med_locker_add_response.dart';
import '../../domain/entities/med_locker_detail.dart';
import '../../domain/entities/med_locker_list_item.dart';
import '../../domain/repositories/med_locker_repository.dart';
import '../data_sources/med_locker_remote_datasource.dart';


class MedLockerRepositoryImpl implements MedLockerRepository {
  final MedLockerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MedLockerRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<MedLockerListItem>>> getMedLockers() async {
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
  Future<Either<Failure, MedLockerDetail>> getMedLockerDetail(int id) async {
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
  Future<Either<Failure, MedLockerAddResponse>> addMedLocker(String name, List<File> images) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final response = await remoteDataSource.addMedLocker(name, images);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}