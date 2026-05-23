import '../entities/coverage_category.dart';
import '../repositories/coverage_category_repository.dart';

class GetCoverageCategories {
  final CoverageCategoryRepository repository;

  GetCoverageCategories(this.repository);

  Future<List<CoverageCategory>> call(String language) async {
    return await repository.getCoverageCategories(language);
  }
}