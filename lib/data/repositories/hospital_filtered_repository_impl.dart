import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/hospital_filtered_repository.dart';
import '../data_sources/hospital_filtered_remote_datasource.dart';

class HospitalFilteredRepositoryImpl implements HospitalFilteredRepository {
  final HospitalFilteredRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  HospitalFilteredRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Hospital>>> getFilteredHospitals({
    required String lang,
    required double lat,
    required double lon,
    required int catId,
    required String specialityIds,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final hospitals = await remoteDataSource.getFilteredHospitals(
        lang: lang,
        lat: lat,
        lon: lon,
        catId: catId,
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