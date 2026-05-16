import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/get_online_doctor_specialities_usecase.dart';
import 'online_doctor_speciality_event.dart';
import 'online_doctor_speciality_state.dart';



class OnlineDoctorSpecialityBloc extends Bloc<OnlineDoctorSpecialityEvent, OnlineDoctorSpecialityState> {
  final GetOnlineDoctorSpecialitiesUseCase getSpecialitiesUseCase;

  OnlineDoctorSpecialityBloc({required this.getSpecialitiesUseCase})
      : super(OnlineDoctorSpecialityInitial()) {
    on<LoadOnlineDoctorSpecialities>(_onLoad);
  }

  Future<void> _onLoad(
      LoadOnlineDoctorSpecialities event,
      Emitter<OnlineDoctorSpecialityState> emit,
      ) async {
    emit(OnlineDoctorSpecialityLoading());
    final result = await getSpecialitiesUseCase(event.lang);
    result.fold(
          (failure) => emit(OnlineDoctorSpecialityError(failure.message)),
          (specialities) => emit(OnlineDoctorSpecialityLoaded(specialities)),
    );
  }
}