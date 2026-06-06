
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/lab_test_category.dart';
import '../repositories/lab_test_category_repository.dart';

class GetLabTestCategories {
  final LabTestCategoryRepository repository;

  GetLabTestCategories(this.repository);

  Future<Either<Failure, List<LabTestCategory>>> call({
    required int page,
    required int perPage,
    required String language,
  }) async {
    return await repository.getCategories(page: page, perPage: perPage, language: language);
  }
}