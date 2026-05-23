part of 'coverage_category_bloc.dart';

abstract class CoverageCategoryEvent {}

class LoadCoverageCategories extends CoverageCategoryEvent {
  final String language;
  LoadCoverageCategories(this.language);
}