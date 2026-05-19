import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../domain/use_cases/get_filtered_hospitals_usecase.dart';
import 'filtered_hospitals_state.dart';
part 'filtered_hospitals_event.dart';


class FilteredHospitalsBloc extends Bloc<FilteredHospitalsEvent, FilteredHospitalsState> {
  final GetFilteredHospitalsUseCase getFilteredHospitalsUseCase;
  FilteredHospitalsBloc({required this.getFilteredHospitalsUseCase}) : super(FilteredHospitalsInitial()) {
    on<LoadFilteredHospitals>(_onLoad);
  }

  Future<void> _onLoad(LoadFilteredHospitals event, Emitter<FilteredHospitalsState> emit) async {
    emit(FilteredHospitalsLoading());
    final result = await getFilteredHospitalsUseCase(GetFilteredHospitalsParams(
      lang: event.lang,
      lat: event.lat,
      lon: event.lon,
      catId: event.catId,
      specialityIds: event.specialityIds,
    ));
    result.fold(
          (failure) => emit(FilteredHospitalsError(failure.message)),
          (hospitals) => emit(FilteredHospitalsLoaded(hospitals)),
    );
  }
}