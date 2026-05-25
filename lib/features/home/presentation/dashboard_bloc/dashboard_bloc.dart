
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/use_cases/get_dashboard.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';


class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUseCase getDashboardUseCase;

  DashboardBloc({required this.getDashboardUseCase}) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final result = await getDashboardUseCase(event.language);
    result.fold(
          (failure) => emit(DashboardError(_mapFailureToMessage(failure))),
          (dashboard) => emit(DashboardLoaded(dashboard)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}