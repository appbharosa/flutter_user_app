import '../../core/errors/failures.dart';
import '../entities/free_lab_report.dart';
import 'package:dartz/dartz.dart';

abstract class FreeLabReportRepository {
  Future<Either<Failure, List<FreeLabReport>>> getFreeLabReports(String language);
}