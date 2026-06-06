import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/get_packages_by_category_id.dart';
import 'lab_test_subcategory_event.dart';
import 'lab_test_subcategory_state.dart';

class LabTestSubcategoryBloc extends Bloc<LabTestSubcategoryEvent, LabTestSubcategoryState> {
  final GetPackagesByCategoryId getPackages;

  LabTestSubcategoryBloc({required this.getPackages}) : super(LabTestSubcategoryInitial()) {
    on<LoadPackagesByCategory>(_onLoadPackages);
  }

  Future<void> _onLoadPackages(LoadPackagesByCategory event, Emitter<LabTestSubcategoryState> emit) async {
    emit(LabTestSubcategoryLoading());
    final result = await getPackages(categoryId: event.categoryId, language: event.language);
    result.fold(
          (failure) => emit(LabTestSubcategoryError(failure.message)),
          (packages) => emit(LabTestSubcategoryLoaded(packages)),
    );
  }
}