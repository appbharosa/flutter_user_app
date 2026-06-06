import 'package:equatable/equatable.dart';

abstract class LabTestSubcategoryEvent extends Equatable {
  const LabTestSubcategoryEvent();
  @override
  List<Object> get props => [];
}

class LoadPackagesByCategory extends LabTestSubcategoryEvent {
  final int categoryId;
  final String language;
  const LoadPackagesByCategory({required this.categoryId, required this.language});
}