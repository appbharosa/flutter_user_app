import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/get_med_lockers_usecase.dart' hide GetMedLockersUseCase, AddMedLockerUseCase;
import '../../../../domain/use_cases/add_med_locker_usecase.dart';
import 'med_locker_event.dart';
import 'med_locker_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import 'med_locker_event.dart';
import 'med_locker_state.dart';

class MedLockerBloc extends Bloc<MedLockerEvent, MedLockerState> {
  final GetMedLockersUseCase getMedLockersUseCase;
  final GetMedLockerDetailUseCase getMedLockerDetailUseCase;
  final AddMedLockerUseCase addMedLockerUseCase;

  MedLockerBloc({
    required this.getMedLockersUseCase,
    required this.getMedLockerDetailUseCase,
    required this.addMedLockerUseCase,
  }) : super(MedLockerInitial()) {
    on<LoadMedLockers>(_onLoadMedLockers);
    on<LoadMedLockerDetail>(_onLoadMedLockerDetail);
    on<AddMedLocker>(_onAddMedLocker);
  }

  Future<void> _onLoadMedLockers(LoadMedLockers event, Emitter<MedLockerState> emit) async {
    emit(MedLockerLoading());
    final result = await getMedLockersUseCase();
    result.fold(
          (failure) => emit(MedLockerError(failure.message)),
          (lockers) => emit(MedLockerListLoaded(lockers)),
    );
  }

  Future<void> _onLoadMedLockerDetail(LoadMedLockerDetail event, Emitter<MedLockerState> emit) async {
    emit(MedLockerDetailLoading());
    final result = await getMedLockerDetailUseCase(event.id);
    result.fold(
          (failure) => emit(MedLockerError(failure.message)),
          (detail) => emit(MedLockerDetailLoaded(detail)),
    );
  }

  Future<void> _onAddMedLocker(AddMedLocker event, Emitter<MedLockerState> emit) async {
    emit(MedLockerAdding());
    final result = await addMedLockerUseCase(event.name, event.images);
    result.fold(
          (failure) => emit(MedLockerError(failure.message)),
          (response) => emit(MedLockerAddSuccess(response)),
    );
  }
}