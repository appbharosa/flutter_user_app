import 'package:bloc/bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../domain/use_cases/get_free_lab_packages.dart';
import 'free_lab_packages_event.dart';
import 'free_lab_packages_state.dart';


class FreeLabPackagesBloc extends Bloc<FreeLabPackagesEvent, FreeLabPackagesState> {
  final GetFreeLabPackagesUseCase getFreeLabPackagesUseCase;

  FreeLabPackagesBloc({required this.getFreeLabPackagesUseCase})
      : super(FreeLabPackagesInitial()) {
    on<LoadFreeLabPackages>(_onLoadPackages);
  }

  Future<void> _onLoadPackages(LoadFreeLabPackages event, Emitter<FreeLabPackagesState> emit) async {
    emit(FreeLabPackagesLoading());
    final result = await getFreeLabPackagesUseCase(event.language);
    result.fold(
          (failure) => emit(FreeLabPackagesError(_mapFailureToMessage(failure))),
          (packages) => emit(FreeLabPackagesLoaded(packages)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}