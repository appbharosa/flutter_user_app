import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../data_sources/hospital_remote_datasource.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HospitalRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Hospital>>> getHospitals({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
    String? specialityIds,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final hospitals = await remoteDataSource.getHospitals(
        page: page,
        perPage: perPage,
        lang: lang,
        lat: lat,
        lon: lon,
        specialityIds: specialityIds,
      );
      return Right(hospitals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}