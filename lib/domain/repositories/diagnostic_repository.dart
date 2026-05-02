import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/diagnostic.dart';

abstract class DiagnosticRepository {
  Future<Either<Failure, List<Diagnostic>>> getDiagnostics({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });
}