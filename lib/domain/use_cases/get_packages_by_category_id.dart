import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/free_lab_package.dart';
import '../repositories/free_lab_repository.dart';

class GetPackagesByCategoryId {
  final FreeLabRepository repository;

  GetPackagesByCategoryId(this.repository);

  Future<Either<Failure, List<FreeLabPackage>>> call({
    required int categoryId,
    required String language,
  }) async {
    return await repository.getPackagesByCategoryId(
      categoryId: categoryId,
      language: language,
    );
  }
}