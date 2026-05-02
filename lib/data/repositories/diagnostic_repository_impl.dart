import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/diagnostic.dart';
import '../../domain/repositories/diagnostic_repository.dart';
import '../data_sources/diagnostic_remote_datasource.dart';

class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final DiagnosticRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DiagnosticRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Diagnostic>>> getDiagnostics({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final diagnostics = await remoteDataSource.getDiagnostics(
        page: page,
        perPage: perPage,
        lang: lang,
        lat: lat,
        lon: lon,
      );
      return Right(diagnostics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}