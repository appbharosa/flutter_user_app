
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../domain/use_cases/get_free_lab_slots.dart';
import 'free_lab_slots_event.dart';
import 'free_lab_slots_state.dart';

class FreeLabSlotsBloc extends Bloc<FreeLabSlotsEvent, FreeLabSlotsState> {
  final GetFreeLabSlotsUseCase getFreeLabSlotsUseCase;

  FreeLabSlotsBloc({required this.getFreeLabSlotsUseCase})
      : super(FreeLabSlotsInitial()) {
    on<LoadFreeLabSlots>(_onLoadSlots);
  }

  Future<void> _onLoadSlots(LoadFreeLabSlots event, Emitter<FreeLabSlotsState> emit) async {
    emit(FreeLabSlotsLoading());
    final result = await getFreeLabSlotsUseCase(
      event.language,
      event.packageId,
      date: event.date, // pass the date
    );
    result.fold(
          (failure) => emit(FreeLabSlotsError(_mapFailureToMessage(failure))),
          (slots) => emit(FreeLabSlotsLoaded(slots)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}