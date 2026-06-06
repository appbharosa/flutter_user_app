
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lab_test_category.dart';
import '../../domain/repositories/lab_test_category_repository.dart';
import '../data_sources/lab_test_category_remote_datasource.dart';


class LabTestCategoryRepositoryImpl implements LabTestCategoryRepository {
  final LabTestCategoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LabTestCategoryRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<LabTestCategory>>> getCategories({
    required int page,
    required int perPage,
    required String language,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final response = await remoteDataSource.getCategories(
        page: page,
        perPage: perPage,
        language: language,
      );
      return Right(response.data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}