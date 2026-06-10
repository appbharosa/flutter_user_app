import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/entities/pharmacy_category.dart';
import '../../domain/entities/pharmacy_product.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../data_sources/pharmacy_remote_datasource.dart';


class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PharmacyRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Pharmacy>>> getPharmacies({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final pharmacies = await remoteDataSource.getPharmacies(
        page: page,
        perPage: perPage,
        lang: lang,
        lat: lat,
        lon: lon,
      );
      return Right(pharmacies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyCategory>>> getCategories(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final categories = await remoteDataSource.getCategories(language);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyProduct>>> getProducts(int categoryId, String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final products = await remoteDataSource.getProducts(categoryId, language);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasMorePages(int currentPage, int total) async {
    try {
      final totalPages = await remoteDataSource.getTotalPages();
      return Right(currentPage < totalPages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}