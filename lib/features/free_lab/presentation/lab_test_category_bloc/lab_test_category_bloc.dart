// lib/presentation/lab_test_category/bloc/lab_test_category_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/lab_test_category.dart';
import '../../../../domain/use_cases/get_lab_test_categories.dart';
import 'lab_test_category_event.dart';
import 'lab_test_category_state.dart';

class LabTestCategoryBloc extends Bloc<LabTestCategoryEvent, LabTestCategoryState> {
  final GetLabTestCategories getCategories;

  List<LabTestCategory> _allCategories = [];
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _perPage = 20;
  String _currentLanguage = 'en';

  LabTestCategoryBloc({required this.getCategories}) : super(LabTestCategoryInitial()) {
    on<LoadLabTestCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(LoadLabTestCategories event, Emitter<LabTestCategoryState> emit) async {
    if (!_hasMore && _currentPage > 1) return;
    if (state is LabTestCategoryLoading) return;

    emit(LabTestCategoryLoading());

    _currentLanguage = event.language;
    final result = await getCategories(
      page: _currentPage,
      perPage: event.perPage,
      language: event.language,
    );

    result.fold(
          (failure) => emit(LabTestCategoryError(failure.message)),
          (newCategories) {
        if (newCategories.isEmpty) {
          _hasMore = false;
          if (_currentPage == 1) emit(LabTestCategoryLoaded(categories: [], hasMore: false, currentPage: _currentPage));
          else emit(LabTestCategoryLoaded(categories: _allCategories, hasMore: false, currentPage: _currentPage));
          return;
        }

        _allCategories.addAll(newCategories);
        _currentPage++;
        _hasMore = newCategories.length == _perPage;
        emit(LabTestCategoryLoaded(categories: List.from(_allCategories), hasMore: _hasMore, currentPage: _currentPage));
      },
    );
  }
}