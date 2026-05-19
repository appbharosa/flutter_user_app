import 'package:bloc/bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/use_cases/get_ecard.dart';
import 'ecard_event.dart';
import 'ecard_state.dart';


class ECardBloc extends Bloc<ECardEvent, ECardState> {
  final GetECardUseCase getECardUseCase;

  ECardBloc({required this.getECardUseCase}) : super(ECardInitial()) {
    on<LoadECard>(_onLoadECard);
  }

  Future<void> _onLoadECard(LoadECard event, Emitter<ECardState> emit) async {
    emit(ECardLoading());
    final result = await getECardUseCase(event.language);
    result.fold(
          (failure) => emit(ECardError(_mapFailureToMessage(failure))),
          (ecard) => emit(ECardLoaded(ecard)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}