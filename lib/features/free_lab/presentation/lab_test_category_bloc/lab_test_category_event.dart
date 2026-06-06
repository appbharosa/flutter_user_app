
import 'package:equatable/equatable.dart';

abstract class LabTestCategoryEvent extends Equatable {
  const LabTestCategoryEvent();
  @override
  List<Object> get props => [];
}

class LoadLabTestCategories extends LabTestCategoryEvent {
  final int page;
  final int perPage;
  final String language;
  const LoadLabTestCategories({
    this.page = 1,
    this.perPage = 20,
    required this.language,
  });
}