import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/get_med_locker_detail_usecase.dart';
import 'med_locker_detail_event.dart';
import 'med_locker_detail_state.dart';


class MedLockerDetailBloc extends Bloc<MedLockerDetailEvent, MedLockerDetailState> {
  final GetMedLockerDetailUseCase getMedLockerDetailUseCase;

  MedLockerDetailBloc({required this.getMedLockerDetailUseCase}) : super(MedLockerDetailInitial()) {
    on<LoadMedLockerDetail>(_onLoadMedLockerDetail);
  }

  Future<void> _onLoadMedLockerDetail(LoadMedLockerDetail event, Emitter<MedLockerDetailState> emit) async {
    emit(MedLockerDetailLoading());
    final result = await getMedLockerDetailUseCase(event.id);
    result.fold(
          (failure) => emit(MedLockerDetailError(failure.message)),
          (locker) => emit(MedLockerDetailLoaded(locker)),
    );
  }
}