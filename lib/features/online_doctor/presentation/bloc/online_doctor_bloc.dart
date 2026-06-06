import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/use_cases/get_online_doctors_usecase.dart';
import 'online_doctor_event.dart';
import 'online_doctor_state.dart';

class OnlineDoctorBloc extends Bloc<OnlineDoctorEvent, OnlineDoctorState> {
  final GetOnlineDoctorsUseCase getDoctorsUseCase;
  final GetTotalPagesUseCase getTotalPagesUseCase;
  final ClearDoctorCacheUseCase clearCacheUseCase;

  List<OnlineDoctor> _allDoctors = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  static const int _perPage = 10;
  String _currentLang = 'en';
  int? _currentSpecialityId;

  OnlineDoctorBloc({
    required this.getDoctorsUseCase,
    required this.getTotalPagesUseCase,
    required this.clearCacheUseCase,
  }) : super(OnlineDoctorInitial()) {
    on<LoadOnlineDoctors>(_onLoadDoctors);
    on<LoadMoreOnlineDoctors>(_onLoadMoreDoctors);
    on<ChangeSpeciality>(_onChangeSpeciality);
  }

  Future<void> _onLoadDoctors(LoadOnlineDoctors event, Emitter<OnlineDoctorState> emit) async {
    emit(OnlineDoctorLoading());
    _resetState();
    _currentLang = event.lang;
    _currentSpecialityId = event.specialityId;
    await _fetchDoctors(emit, isFirstLoad: true);
  }

  Future<void> _onLoadMoreDoctors(LoadMoreOnlineDoctors event, Emitter<OnlineDoctorState> emit) async {
    if (_currentPage > _totalPages || _isLoadingMore) {
      debugPrint('🚫 Load more blocked: currentPage=$_currentPage, totalPages=$_totalPages, isLoadingMore=$_isLoadingMore');
      return;
    }
    debugPrint('📥 Loading more: page $_currentPage of $_totalPages');
    _isLoadingMore = true;
    await _fetchDoctors(emit, isFirstLoad: false);
    _isLoadingMore = false;
  }

  Future<void> _onChangeSpeciality(ChangeSpeciality event, Emitter<OnlineDoctorState> emit) async {
    emit(OnlineDoctorLoading());
    _resetState();
    _currentSpecialityId = event.specialityId;
    await _fetchDoctors(emit, isFirstLoad: true);
  }

  void _resetState() {
    _allDoctors = [];
    _currentPage = 1;
    _totalPages = 1;
    _isLoadingMore = false;
    clearCacheUseCase();
  }

  Future<void> _fetchDoctors(Emitter<OnlineDoctorState> emit, {required bool isFirstLoad}) async {
    debugPrint('🔍 Fetching page $_currentPage, isFirstLoad=$isFirstLoad');
    final result = await getDoctorsUseCase(GetOnlineDoctorsParams(
      page: _currentPage,
      perPage: _perPage,
      lang: _currentLang,
      specialityId: _currentSpecialityId,
    ));

    await result.fold(
          (failure) async {
        debugPrint('❌ API error: ${failure.message}');
        if (isFirstLoad) {
          emit(OnlineDoctorError(failure.message));
        } else {
          _totalPages = _currentPage;
          emit(OnlineDoctorLoaded(List.from(_allDoctors), false, _currentSpecialityId));
        }
      },
          (newDoctors) async {
        debugPrint('✅ Received ${newDoctors.length} doctors for page $_currentPage');
        if (newDoctors.isEmpty) {
          debugPrint('⚠️ No doctors returned – assuming last page');
          _totalPages = _currentPage;
          emit(OnlineDoctorLoaded(List.from(_allDoctors), false, _currentSpecialityId));
          return;
        }

        // Append new doctors (do not replace)
        _allDoctors.addAll(newDoctors);
        debugPrint('📊 Total doctors now: ${_allDoctors.length}');

        // Increment page number for the next fetch
        _currentPage++;
        debugPrint('➡️ Incremented page to: $_currentPage');

        // Get total pages only once after the first successful load
        if (isFirstLoad) {
          final totalResult = await getTotalPagesUseCase();
          totalResult.fold(
                (failure) => _totalPages = _currentPage,
                (total) => _totalPages = total,
          );
          debugPrint('📄 Total pages: $_totalPages');
        }

        final hasMore = _currentPage <= _totalPages;
        debugPrint('🏁 Emitting state: hasMore=$hasMore, total doctors=${_allDoctors.length}');
        emit(OnlineDoctorLoaded(List.from(_allDoctors), hasMore, _currentSpecialityId));
      },
    );
  }
}