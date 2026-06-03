import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/free_lab_report.dart';
import '../../domain/repositories/free_lab_report_repository.dart';
import '../data_sources/free_lab_report_remote_datasource.dart';
import '../models/free_lab_report_model.dart';
import 'package:dartz/dartz.dart';

class FreeLabReportRepositoryImpl implements FreeLabReportRepository {
  final FreeLabReportRemoteDataSource remoteDataSource;

  FreeLabReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<FreeLabReport>>> getFreeLabReports(String language) async {
    try {
      final data = await remoteDataSource.getFreeLabReports(language);
      final reports = data.map((json) => FreeLabReportModel.fromJson(json)).toList();
      return Right(reports);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}