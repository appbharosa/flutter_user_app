
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/free_lab_package.dart';

abstract class LabTestSubcategoryState extends Equatable {
  const LabTestSubcategoryState();
  @override
  List<Object> get props => [];
}

class LabTestSubcategoryInitial extends LabTestSubcategoryState {}

class LabTestSubcategoryLoading extends LabTestSubcategoryState {}

class LabTestSubcategoryLoaded extends LabTestSubcategoryState {
  final List<FreeLabPackage> packages;
  const LabTestSubcategoryLoaded(this.packages);
  @override
  List<Object> get props => [packages];
}

class LabTestSubcategoryError extends LabTestSubcategoryState {
  final String message;
  const LabTestSubcategoryError(this.message);
  @override
  List<Object> get props => [message];
}