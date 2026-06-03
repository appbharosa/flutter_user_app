import '../../core/errors/failures.dart';
import '../entities/free_lab_report.dart';
import '../repositories/free_lab_report_repository.dart';
import 'package:dartz/dartz.dart';


class GetFreeLabReports {
  final FreeLabReportRepository repository;

  GetFreeLabReports(this.repository);

  Future<Either<Failure, List<FreeLabReport>>> call(String language) async {
    return await repository.getFreeLabReports(language);
  }
}