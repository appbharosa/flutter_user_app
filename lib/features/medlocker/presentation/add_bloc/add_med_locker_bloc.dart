import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/add_med_locker_usecase.dart';
import 'add_med_locker_event.dart';
import 'add_med_locker_state.dart';


class AddMedLockerBloc extends Bloc<AddMedLockerEvent, AddMedLockerState> {
  final AddMedLockerUseCase addMedLockerUseCase;

  AddMedLockerBloc({required this.addMedLockerUseCase}) : super(AddMedLockerInitial()) {
    on<AddMedLockerSubmitted>(_onAddMedLockerSubmitted);
  }

  Future<void> _onAddMedLockerSubmitted(AddMedLockerSubmitted event, Emitter<AddMedLockerState> emit) async {
    emit(AddMedLockerLoading());
    final result = await addMedLockerUseCase(AddMedLockerParams(
      name: event.name,
      imagePaths: event.imagePaths,
    ));
    result.fold(
          (failure) => emit(AddMedLockerError(failure.message)),
          (locker) => emit(AddMedLockerSuccess(locker)),
    );
  }
}