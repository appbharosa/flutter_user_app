import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/get_med_lockers_usecase.dart';
import 'med_locker_event.dart';
import 'med_locker_state.dart';


class MedLockerBloc extends Bloc<MedLockerEvent, MedLockerState> {
  final GetMedLockersUseCase getMedLockersUseCase;

  MedLockerBloc({required this.getMedLockersUseCase}) : super(MedLockerInitial()) {
    on<LoadMedLockers>(_onLoadMedLockers);
  }

  Future<void> _onLoadMedLockers(LoadMedLockers event, Emitter<MedLockerState> emit) async {
    emit(MedLockerLoading());
    final result = await getMedLockersUseCase();
    result.fold(
          (failure) => emit(MedLockerError(failure.message)),
          (lockers) => emit(MedLockerLoaded(lockers)),
    );
  }
}