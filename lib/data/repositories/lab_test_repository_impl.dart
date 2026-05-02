import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lab_test.dart';
import '../../domain/repositories/lab_test_repository.dart';
import '../data_sources/lab_test_remote_datasource.dart';

class LabTestRepositoryImpl implements LabTestRepository {
  final LabTestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LabTestRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<LabTest>>> getLabTests({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final labTests = await remoteDataSource.getLabTests(
        page: page,
        perPage: perPage,
        lang: lang,
        lat: lat,
        lon: lon,
      );
      return Right(labTests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}