import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/use_cases/get_lab_slots_usecase.dart';
import '../../../../domain/entities/lab_slots_response.dart';



class LabSlotBloc extends Bloc<LabSlotEvent, LabSlotState> {
  final GetLabSlotsUseCase getSlotsUseCase;
  LabSlotBloc({required this.getSlotsUseCase}) : super(LabSlotInitial()) {
    on<LoadLabSlots>(_onLoadSlots);
  }

  Future<void> _onLoadSlots(LoadLabSlots event, Emitter<LabSlotState> emit) async {
    print("🚀 LabSlotBloc: loading slots for date ${event.date}");
    emit(LabSlotLoading());
    final result = await getSlotsUseCase(event.date);
    result.fold(
          (failure) {
        print("❌ LabSlotBloc error: ${failure.message}");
        emit(LabSlotError(failure.message));
      },
          (slots) {
        print("✅ LabSlotBloc success: sessions count = ${slots.sessions.length}");
        emit(LabSlotLoaded(slots));
      },
    );
  }
}

// events
abstract class LabSlotEvent {}
class LoadLabSlots extends LabSlotEvent {
  final String date;
  LoadLabSlots(this.date);
}

// states
abstract class LabSlotState {}
class LabSlotInitial extends LabSlotState {}
class LabSlotLoading extends LabSlotState {}
class LabSlotLoaded extends LabSlotState {
  final LabSlotsResponse slots;
  LabSlotLoaded(this.slots);
}
class LabSlotError extends LabSlotState {
  final String message;
  LabSlotError(this.message);
}