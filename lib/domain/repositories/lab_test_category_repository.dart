// lib/domain/repositories/lab_test_category_repository.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/lab_test_category.dart';

abstract class LabTestCategoryRepository {
  Future<Either<Failure, List<LabTestCategory>>> getCategories({
    required int page,
    required int perPage,
    required String language,
  });
}