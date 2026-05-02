import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/hospital.dart';
import '../../../../domain/use_cases/get_hospitals_usecase.dart';
import 'hospital_event.dart';
import 'hospital_state.dart';


class HospitalBloc extends Bloc<HospitalEvent, HospitalState> {
  final GetHospitalsUseCase getHospitalsUseCase;
  List<Hospital> _allHospitals = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _perPage = 15;
  double _lat = 0.0;
  double _lon = 0.0;
  String _lang = 'en';

  HospitalBloc({required this.getHospitalsUseCase}) : super(HospitalInitial()) {
    on<LoadHospitals>(_onLoadHospitals);
    on<LoadMoreHospitals>(_onLoadMoreHospitals);
  }

  Future<void> _onLoadHospitals(LoadHospitals event, Emitter<HospitalState> emit) async {
    emit(HospitalLoading());
    _allHospitals = [];
    _currentPage = 1;
    _hasMore = true;
    _lat = event.lat;
    _lon = event.lon;
    _lang = event.lang;
    await _fetchHospitals(emit, isFirstLoad: true);
  }

  Future<void> _onLoadMoreHospitals(LoadMoreHospitals event, Emitter<HospitalState> emit) async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    await _fetchHospitals(emit, isFirstLoad: false);
    _isLoadingMore = false;
  }

  Future<void> _fetchHospitals(Emitter<HospitalState> emit, {required bool isFirstLoad}) async {
    final result = await getHospitalsUseCase(GetHospitalsParams(
      page: _currentPage,
      perPage: _perPage,
      lang: _lang,
      lat: _lat,
      lon: _lon,
    ));
    result.fold(
          (failure) => emit(HospitalError(failure.message)),
          (newHospitals) {
        if (newHospitals.isEmpty) {
          _hasMore = false;
          if (isFirstLoad) emit(HospitalLoaded([], false));
        } else {
          _allHospitals.addAll(newHospitals);
          _currentPage++;
          _hasMore = newHospitals.length == _perPage;
          emit(HospitalLoaded(List.from(_allHospitals), _hasMore));
        }
      },
    );
  }
}