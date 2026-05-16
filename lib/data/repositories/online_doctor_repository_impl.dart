import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/online_doctor.dart';
import '../../domain/repositories/online_doctor_repository.dart';
import '../data_sources/online_doctor_remote_datasource.dart';

class OnlineDoctorRepositoryImpl implements OnlineDoctorRepository {
  final OnlineDoctorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  OnlineDoctorRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<OnlineDoctor>>> getDoctors({
    required int page,
    required int perPage,
    required String lang,
    int? specialityId,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final doctors = await remoteDataSource.getDoctors(
        page: page,
        perPage: perPage,
        lang: lang,
        specialityId: specialityId,
      );
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalPages() async {
    try {
      final totalPages = await remoteDataSource.getTotalPages();
      return Right(totalPages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}