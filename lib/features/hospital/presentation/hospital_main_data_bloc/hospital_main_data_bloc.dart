import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/domain/use_cases/get_hospital_main_data_usecase.dart';
import 'hospital_main_data_event.dart';
import 'hospital_main_data_state.dart';


class HospitalMainDataBloc extends Bloc<HospitalMainDataEvent, HospitalMainDataState> {
  final GetHospitalMainDataUseCase getHospitalDataUseCase;
  HospitalMainDataBloc({required this.getHospitalDataUseCase}) : super(HospitalMainDataInitial()) {
    on<LoadHospitalMainData>(_onLoad);
  }

  Future<void> _onLoad(LoadHospitalMainData event, Emitter<HospitalMainDataState> emit) async {
    emit(HospitalMainDataLoading());
    // ✅ Pass both arguments (positional)
    final result = await getHospitalDataUseCase(event.mainDataId, event.lang);
    result.fold(
          (failure) => emit(HospitalMainDataError(failure.message)),
          (data) {
        final hospital = data.$1;
        final doctors = data.$2;
        emit(HospitalMainDataLoaded(hospital, doctors));
      },
    );
  }
}