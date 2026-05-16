import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/online_doctor_slots_response.dart';
import '../../../../domain/use_cases/get_online_doctor_slots_usecase.dart';
part 'online_doctor_slot_event.dart';
part 'online_doctor_slot_state.dart';

class OnlineDoctorSlotBloc extends Bloc<OnlineDoctorSlotEvent, OnlineDoctorSlotState> {
  final GetOnlineDoctorSlotsUseCase getSlotsUseCase;
  OnlineDoctorSlotBloc({required this.getSlotsUseCase}) : super(OnlineDoctorSlotInitial()) {
    on<LoadOnlineDoctorSlots>(_onLoadSlots);
  }

  Future<void> _onLoadSlots(LoadOnlineDoctorSlots event, Emitter<OnlineDoctorSlotState> emit) async {
    emit(OnlineDoctorSlotLoading());
    final result = await getSlotsUseCase(event.date);
    result.fold(
          (failure) => emit(OnlineDoctorSlotError(failure.message)),
          (slots) => emit(OnlineDoctorSlotLoaded(slots)),
    );
  }
}