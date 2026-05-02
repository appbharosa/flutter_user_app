import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/about.dart';
import '../../domain/repositories/about_repository.dart';
import '../data_sources/about_remote_datasource.dart';

class AboutRepositoryImpl implements AboutRepository {
  final AboutRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AboutRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, About>> getAbout() async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure());
    }
    try {
      final aboutModel = await remoteDataSource.getAbout();
      return Right(aboutModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}