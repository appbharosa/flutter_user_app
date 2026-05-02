import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/pharmacy/presentation/bloc/pharmacy_event.dart';
import 'package:user/features/pharmacy/presentation/bloc/pharmacy_state.dart';
import '../../../../domain/entities/pharmacy.dart';
import '../../../../domain/use_cases/get_pharmacies_usecase.dart';



class PharmacyBloc extends Bloc<PharmacyEvent, PharmacyState> {
  final GetPharmaciesUseCase getPharmaciesUseCase;
  List<Pharmacy> _allPharmacies = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _perPage = 15;
  double _lat = 0.0;
  double _lon = 0.0;
  String _lang = 'en';

  PharmacyBloc({required this.getPharmaciesUseCase}) : super(PharmacyInitial()) {
    on<LoadPharmacies>(_onLoadPharmacies);
    on<LoadMorePharmacies>(_onLoadMorePharmacies);
  }

  Future<void> _onLoadPharmacies(LoadPharmacies event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    _allPharmacies = [];
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lat = event.lat;
    _lon = event.lon;
    _lang = event.lang;
    await _fetchPharmacies(emit, isFirstLoad: true);
  }

  Future<void> _onLoadMorePharmacies(LoadMorePharmacies event, Emitter<PharmacyState> emit) async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    await _fetchPharmacies(emit, isFirstLoad: false);
    _isLoadingMore = false;
  }

  Future<void> _fetchPharmacies(Emitter<PharmacyState> emit, {required bool isFirstLoad}) async {
    final result = await getPharmaciesUseCase(GetPharmaciesParams(
      page: _currentPage,
      perPage: _perPage,
      lang: _lang,
      lat: _lat,
      lon: _lon,
    ));
    result.fold(
          (failure) => emit(PharmacyError(failure.message)),
          (newPharmacies) {
        if (newPharmacies.isEmpty) {
          _hasMore = false;
          if (isFirstLoad) emit(PharmacyLoaded([], false));
        } else {
          _allPharmacies.addAll(newPharmacies);
          _currentPage++;
          _hasMore = newPharmacies.length == _perPage;
          emit(PharmacyLoaded(List.from(_allPharmacies), _hasMore));
        }
      },
    );
  }
}