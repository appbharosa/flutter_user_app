import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pharmacy_product.dart';
import '../repositories/pharmacy_repository.dart';

class GetPharmacyProducts {
  final PharmacyRepository repository;

  GetPharmacyProducts(this.repository);

  Future<Either<Failure, List<PharmacyProduct>>> call(int categoryId, String language) async {
    return await repository.getProducts(categoryId, language);
  }
}