import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../data_sources/banner_remote_datasource.dart';


class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BannerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Banner>>> getBanners() async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure());
    }
    try {
      final banners = await remoteDataSource.getBanners();
      return Right(banners);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}