import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/lab_test.dart';
import '../../../../domain/use_cases/get_lab_tests_usecase.dart';
import 'lab_test_event.dart';
import 'lab_test_state.dart';


class LabTestBloc extends Bloc<LabTestEvent, LabTestState> {
  final GetLabTestsUseCase getLabTestsUseCase;
  List<LabTest> _allLabTests = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _perPage = 15;
  double _lat = 0.0;
  double _lon = 0.0;
  String _lang = 'en';

  LabTestBloc({required this.getLabTestsUseCase}) : super(LabTestInitial()) {
    on<LoadLabTests>(_onLoadLabTests);
    on<LoadMoreLabTests>(_onLoadMoreLabTests);
  }

  Future<void> _onLoadLabTests(LoadLabTests event, Emitter<LabTestState> emit) async {
    emit(LabTestLoading());
    _allLabTests = [];
    _currentPage = 1;
    _hasMore = true;
    _lat = event.lat;
    _lon = event.lon;
    _lang = event.lang;
    await _fetchLabTests(emit, isFirstLoad: true);
  }

  Future<void> _onLoadMoreLabTests(LoadMoreLabTests event, Emitter<LabTestState> emit) async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    await _fetchLabTests(emit, isFirstLoad: false);
    _isLoadingMore = false;
  }

  Future<void> _fetchLabTests(Emitter<LabTestState> emit, {required bool isFirstLoad}) async {
    final result = await getLabTestsUseCase(GetLabTestsParams(
      page: _currentPage,
      perPage: _perPage,
      lang: _lang,
      lat: _lat,
      lon: _lon,
    ));
    result.fold(
          (failure) => emit(LabTestError(failure.message)),
          (newLabTests) {
        if (newLabTests.isEmpty) {
          _hasMore = false;
          if (isFirstLoad) emit(LabTestLoaded([], false));
        } else {
          _allLabTests.addAll(newLabTests);
          _currentPage++;
          _hasMore = newLabTests.length == _perPage;
          emit(LabTestLoaded(List.from(_allLabTests), _hasMore));
        }
      },
    );
  }
}