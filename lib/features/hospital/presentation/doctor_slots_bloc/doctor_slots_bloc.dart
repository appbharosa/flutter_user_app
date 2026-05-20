// lib/features/doctor_booking/presentation/bloc/doctor_slots_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/doctor_slot.dart';
import '../../../../domain/use_cases/get_doctor_slots.dart';
part 'doctor_slots_event.dart';
part 'doctor_slots_state.dart';

class DoctorSlotsBloc extends Bloc<DoctorSlotsEvent, DoctorSlotsState> {
  final GetDoctorSlotsUseCase getDoctorSlotsUseCase;

  DoctorSlotsBloc({required this.getDoctorSlotsUseCase})
      : super(DoctorSlotsInitial()) {
    on<LoadDoctorSlots>(_onLoadDoctorSlots);
  }

  Future<void> _onLoadDoctorSlots(LoadDoctorSlots event, Emitter<DoctorSlotsState> emit) async {
    emit(DoctorSlotsLoading());
    final result = await getDoctorSlotsUseCase(
      doctorId: event.doctorId,
      language: event.language,

    );
    result.fold(
          (failure) => emit(DoctorSlotsError(_mapFailureToMessage(failure))),
          (slots) => emit(DoctorSlotsLoaded(slots)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}