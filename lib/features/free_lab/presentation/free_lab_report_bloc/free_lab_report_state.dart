
import '../../../../domain/entities/free_lab_report.dart';

abstract class FreeLabReportState {}

class FreeLabReportInitial extends FreeLabReportState {}

class FreeLabReportLoading extends FreeLabReportState {}

class FreeLabReportLoaded extends FreeLabReportState {
  final List<FreeLabReport> reports;
  FreeLabReportLoaded(this.reports);
}

class FreeLabReportError extends FreeLabReportState {
  final String message;
  FreeLabReportError(this.message);
}