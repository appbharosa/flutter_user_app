import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/language_service.dart';
import '../../../../domain/use_cases/get_free_lab_reports.dart';
import 'free_lab_report_event.dart';
import 'free_lab_report_state.dart';

class FreeLabReportBloc extends Bloc<FreeLabReportEvent, FreeLabReportState> {
  final GetFreeLabReports getFreeLabReports;

  FreeLabReportBloc({required this.getFreeLabReports}) : super(FreeLabReportInitial()) {
    on<LoadFreeLabReports>(_onLoad);
  }

  Future<void> _onLoad(LoadFreeLabReports event, Emitter<FreeLabReportState> emit) async {
    emit(FreeLabReportLoading());
    final language = await LanguageService.getCurrentLanguage();
    final result = await getFreeLabReports(language);
    result.fold(
          (failure) => emit(FreeLabReportError(failure.message)),
          (reports) => emit(FreeLabReportLoaded(reports)),
    );
  }
}