import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/use_cases/get_online_doctors_usecase.dart';
import 'online_doctor_event.dart';
import 'online_doctor_state.dart';


class OnlineDoctorBloc extends Bloc<OnlineDoctorEvent, OnlineDoctorState> {
  final GetOnlineDoctorsUseCase getDoctorsUseCase;
  List<OnlineDoctor> _allDoctors = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _perPage = 10;
  String _currentLang = 'en';
  int? _currentSpecialityId;

  OnlineDoctorBloc({required this.getDoctorsUseCase}) : super(OnlineDoctorInitial()) {
    on<LoadOnlineDoctors>(_onLoadDoctors);
    on<LoadMoreOnlineDoctors>(_onLoadMoreDoctors);
    on<ChangeSpeciality>(_onChangeSpeciality);
  }

  Future<void> _onLoadDoctors(LoadOnlineDoctors event, Emitter<OnlineDoctorState> emit) async {
    emit(OnlineDoctorLoading());
    _allDoctors = [];
    _currentPage = 1;
    _hasMore = true;
    _currentLang = event.lang;
    _currentSpecialityId = event.specialityId;
    await _fetchDoctors(emit, isFirstLoad: true);
  }

  Future<void> _onLoadMoreDoctors(LoadMoreOnlineDoctors event, Emitter<OnlineDoctorState> emit) async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    await _fetchDoctors(emit, isFirstLoad: false);
    _isLoadingMore = false;
  }

  Future<void> _onChangeSpeciality(ChangeSpeciality event, Emitter<OnlineDoctorState> emit) async {
    emit(OnlineDoctorLoading());
    _allDoctors = [];
    _currentPage = 1;
    _hasMore = true;
    _currentSpecialityId = event.specialityId;
    await _fetchDoctors(emit, isFirstLoad: true);
  }

  Future<void> _fetchDoctors(Emitter<OnlineDoctorState> emit, {required bool isFirstLoad}) async {
    final result = await getDoctorsUseCase(GetOnlineDoctorsParams(
      page: _currentPage,
      perPage: _perPage,
      lang: _currentLang,
      specialityId: _currentSpecialityId,
    ));
    result.fold(
          (failure) => emit(OnlineDoctorError(failure.message)),
          (newDoctors) {
        if (newDoctors.isEmpty) {
          _hasMore = false;
          if (isFirstLoad) emit(OnlineDoctorLoaded([], false, _currentSpecialityId));
        } else {
          _allDoctors.addAll(newDoctors);
          _currentPage++;
          // ✅ Fix: compare length to _perPage (10)
          _hasMore = newDoctors.length == _perPage;
          emit(OnlineDoctorLoaded(List.from(_allDoctors), _hasMore, _currentSpecialityId));
        }
      },
    );
  }
}