import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pharmacy_category.dart';
import '../repositories/pharmacy_repository.dart';

class GetPharmacyCategories {
  final PharmacyRepository repository;

  GetPharmacyCategories(this.repository);

  Future<Either<Failure, List<PharmacyCategory>>> call(String language) async {
    return await repository.getCategories(language);
  }
}