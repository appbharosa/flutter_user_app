import '../../domain/entities/coverage_category.dart';
import '../../domain/repositories/coverage_category_repository.dart';
import '../data_sources/coverage_category_remote_datasource.dart';

class CoverageCategoryRepositoryImpl implements CoverageCategoryRepository {
  final CoverageCategoryRemoteDataSource remoteDataSource;

  CoverageCategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CoverageCategory>> getCoverageCategories(String language) async {
    final data = await remoteDataSource.getCoverageCategories(language);
    return data.map((json) => CoverageCategory.fromJson(json)).toList();
  }
}