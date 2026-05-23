import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/use_cases/get_coverage_categories.dart';
import 'coverage_category_state.dart';

part 'coverage_category_event.dart';

class CoverageCategoryBloc extends Bloc<CoverageCategoryEvent, CoverageCategoryState> {
  final GetCoverageCategories getCoverageCategories;

  CoverageCategoryBloc({required this.getCoverageCategories}) : super(CoverageCategoryInitial()) {
    on<LoadCoverageCategories>(_onLoad);
  }

  Future<void> _onLoad(LoadCoverageCategories event, Emitter<CoverageCategoryState> emit) async {
    emit(CoverageCategoryLoading());
    try {
      final categories = await getCoverageCategories(event.language);
      emit(CoverageCategoryLoaded(categories));
    } catch (e) {
      emit(CoverageCategoryError(e.toString()));
    }
  }
}