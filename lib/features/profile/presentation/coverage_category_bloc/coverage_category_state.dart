
import '../../../../domain/entities/coverage_category.dart';

abstract class CoverageCategoryState {}

class CoverageCategoryInitial extends CoverageCategoryState {}

class CoverageCategoryLoading extends CoverageCategoryState {}

class CoverageCategoryLoaded extends CoverageCategoryState {
  final List<CoverageCategory> categories;
  CoverageCategoryLoaded(this.categories);
}

class CoverageCategoryError extends CoverageCategoryState {
  final String message;
  CoverageCategoryError(this.message);
}