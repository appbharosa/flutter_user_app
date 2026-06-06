// lib/presentation/lab_test_category/bloc/lab_test_category_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/lab_test_category.dart';

abstract class LabTestCategoryState extends Equatable {
  const LabTestCategoryState();
  @override
  List<Object> get props => [];
}

class LabTestCategoryInitial extends LabTestCategoryState {}

class LabTestCategoryLoading extends LabTestCategoryState {}

class LabTestCategoryLoaded extends LabTestCategoryState {
  final List<LabTestCategory> categories;
  final bool hasMore;
  final int currentPage;

  const LabTestCategoryLoaded({
    required this.categories,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object> get props => [categories, hasMore, currentPage];
}

class LabTestCategoryError extends LabTestCategoryState {
  final String message;
  const LabTestCategoryError(this.message);
  @override
  List<Object> get props => [message];
}