import 'package:equatable/equatable.dart';
import '../../../../domain/entities/pharmacy_category.dart';
import '../../../../domain/entities/pharmacy_product.dart';

abstract class PharmacyCategoryState extends Equatable {
  const PharmacyCategoryState();
  @override
  List<Object> get props => [];
}

class PharmacyInitial extends PharmacyCategoryState {}

class PharmacyLoading extends PharmacyCategoryState {}

class PharmacyCategoriesLoaded extends PharmacyCategoryState {
  final List<PharmacyCategory> categories;
  const PharmacyCategoriesLoaded(this.categories);
}

class PharmacyProductsLoaded extends PharmacyCategoryState {
  final List<PharmacyProduct> products;
  const PharmacyProductsLoaded(this.products);
}

class PharmacyCategoryError extends PharmacyCategoryState {
  final String message;
  const PharmacyCategoryError(this.message);
}