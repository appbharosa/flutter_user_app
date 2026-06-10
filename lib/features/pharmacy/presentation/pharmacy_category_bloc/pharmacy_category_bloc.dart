import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_category_bloc/pharmacy_category_event.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_category_bloc/pharmacy_category_state.dart';

import '../../../../core/services/language_service.dart';
import '../../../../domain/use_cases/get_pharmacy_categories.dart';
import '../../../../domain/use_cases/get_pharmacy_products.dart';


class PharmacyCategoryBloc extends Bloc<PharmacyCategoryEvent, PharmacyCategoryState> {
  final GetPharmacyCategories getCategories;
  final GetPharmacyProducts getProducts;

  PharmacyCategoryBloc({required this.getCategories, required this.getProducts})
      : super(PharmacyInitial()) {
    on<LoadPharmacyCategories>(_onLoadCategories);
    on<LoadPharmacyProducts>(_onLoadProducts);
  }

  Future<void> _onLoadCategories(LoadPharmacyCategories event, Emitter<PharmacyCategoryState> emit) async {
    emit(PharmacyLoading());
    final language = await LanguageService.getCurrentLanguage();
    final result = await getCategories(language);
    result.fold(
          (failure) => emit(PharmacyCategoryError(failure.message)),
          (categories) => emit(PharmacyCategoriesLoaded(categories)),
    );
  }

  Future<void> _onLoadProducts(LoadPharmacyProducts event, Emitter<PharmacyCategoryState> emit) async {
    emit(PharmacyLoading());
    final language = await LanguageService.getCurrentLanguage();
    final result = await getProducts(event.categoryId, language);
    result.fold(
          (failure) => emit(PharmacyCategoryError(failure.message)),
          (products) => emit(PharmacyProductsLoaded(products)),
    );
  }
}