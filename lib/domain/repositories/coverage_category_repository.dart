import '../entities/coverage_category.dart';

abstract class CoverageCategoryRepository {
  Future<List<CoverageCategory>> getCoverageCategories(String language);
}