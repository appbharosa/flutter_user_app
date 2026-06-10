import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pharmacy.dart';
import '../entities/pharmacy_category.dart';
import '../entities/pharmacy_product.dart';

abstract class PharmacyRepository {
  Future<Either<Failure, List<Pharmacy>>> getPharmacies({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });
  Future<Either<Failure, bool>> hasMorePages(int currentPage, int total);
  Future<Either<Failure, List<PharmacyCategory>>> getCategories(String language);
  Future<Either<Failure, List<PharmacyProduct>>> getProducts(int categoryId, String language);
}

