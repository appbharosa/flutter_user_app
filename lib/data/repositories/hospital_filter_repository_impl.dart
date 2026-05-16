import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/hospital_filter_category.dart';
import '../../domain/repositories/hospital_filter_repository.dart';
import '../data_sources/hospital_filter_remote_datasource.dart';


class HospitalFilterRepositoryImpl implements HospitalFilterRepository {
  final HospitalFilterRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  HospitalFilterRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<HospitalFilterCategory>>> getFilters() async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final filters = await remoteDataSource.getFilters();
      return Right(filters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}