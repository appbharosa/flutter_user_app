import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pharmacy.dart';

abstract class PharmacyRepository {
  Future<Either<Failure, List<Pharmacy>>> getPharmacies({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });
  Future<Either<Failure, bool>> hasMorePages(int currentPage, int total);
}