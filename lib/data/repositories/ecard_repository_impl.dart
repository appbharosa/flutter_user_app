
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ecard.dart';
import '../../domain/repositories/ecard_repository.dart';
import '../data_sources/ecard_remote_datasource.dart';

class ECardRepositoryImpl implements ECardRepository {
  final ECardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ECardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ECard>> getECard(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final ecard = await remoteDataSource.getECard(language);
      return Right(ecard);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}