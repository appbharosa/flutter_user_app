import 'package:equatable/equatable.dart';

abstract class PharmacyCategoryEvent extends Equatable {
  const PharmacyCategoryEvent();
  @override
  List<Object> get props => [];
}

class LoadPharmacyCategories extends PharmacyCategoryEvent {}

class LoadPharmacyProducts extends PharmacyCategoryEvent {
  final int categoryId;
  const LoadPharmacyProducts(this.categoryId);
}