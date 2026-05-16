
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/get_hospital_filters_usecase.dart';
import 'hospital_filters_event.dart';
import 'hospital_filters_state.dart';

class HospitalFiltersBloc extends Bloc<HospitalFiltersEvent, HospitalFiltersState> {
  final GetHospitalFiltersUseCase getFiltersUseCase;
  HospitalFiltersBloc({required this.getFiltersUseCase}) : super(HospitalFiltersInitial()) {
    on<LoadHospitalFilters>(_onLoad);
  }

  Future<void> _onLoad(LoadHospitalFilters event, Emitter<HospitalFiltersState> emit) async {
    emit(HospitalFiltersLoading());
    final result = await getFiltersUseCase();
    result.fold(
          (failure) => emit(HospitalFiltersError(failure.message)),
          (categories) => emit(HospitalFiltersLoaded(categories)),
    );
  }
}