import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/diagnostic.dart';
import '../../../../domain/use_cases/get_diagnostics_usecase.dart';
import 'diagnostic_event.dart';
import 'diagnostic_state.dart';


class DiagnosticBloc extends Bloc<DiagnosticEvent, DiagnosticState> {
  final GetDiagnosticsUseCase getDiagnosticsUseCase;
  List<Diagnostic> _allDiagnostics = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _perPage = 15;
  double _lat = 0.0;
  double _lon = 0.0;
  String _lang = 'en';

  DiagnosticBloc({required this.getDiagnosticsUseCase}) : super(DiagnosticInitial()) {
    on<LoadDiagnostics>(_onLoadDiagnostics);
    on<LoadMoreDiagnostics>(_onLoadMoreDiagnostics);
  }

  Future<void> _onLoadDiagnostics(LoadDiagnostics event, Emitter<DiagnosticState> emit) async {
    emit(DiagnosticLoading());
    _allDiagnostics = [];
    _currentPage = 1;
    _hasMore = true;
    _lat = event.lat;
    _lon = event.lon;
    _lang = event.lang;
    await _fetchDiagnostics(emit, isFirstLoad: true);
  }

  Future<void> _onLoadMoreDiagnostics(LoadMoreDiagnostics event, Emitter<DiagnosticState> emit) async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    await _fetchDiagnostics(emit, isFirstLoad: false);
    _isLoadingMore = false;
  }

  Future<void> _fetchDiagnostics(Emitter<DiagnosticState> emit, {required bool isFirstLoad}) async {
    final result = await getDiagnosticsUseCase(GetDiagnosticsParams(
      page: _currentPage,
      perPage: _perPage,
      lang: _lang,
      lat: _lat,
      lon: _lon,
    ));
    result.fold(
          (failure) => emit(DiagnosticError(failure.message)),
          (newDiagnostics) {
        if (newDiagnostics.isEmpty) {
          _hasMore = false;
          if (isFirstLoad) emit(DiagnosticLoaded([], false));
        } else {
          _allDiagnostics.addAll(newDiagnostics);
          _currentPage++;
          _hasMore = newDiagnostics.length == _perPage;
          emit(DiagnosticLoaded(List.from(_allDiagnostics), _hasMore));
        }
      },
    );
  }
}