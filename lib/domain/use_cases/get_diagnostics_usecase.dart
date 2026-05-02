import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/diagnostic.dart';
import '../repositories/diagnostic_repository.dart';


class GetDiagnosticsParams {
  final int page;
  final int perPage;
  final String lang;
  final double lat;
  final double lon;

  GetDiagnosticsParams({
    required this.page,
    required this.perPage,
    required this.lang,
    required this.lat,
    required this.lon,
  });
}

class GetDiagnosticsUseCase {
  final DiagnosticRepository repository;

  GetDiagnosticsUseCase(this.repository);

  Future<Either<Failure, List<Diagnostic>>> call(GetDiagnosticsParams params) async {
    return await repository.getDiagnostics(
      page: params.page,
      perPage: params.perPage,
      lang: params.lang,
      lat: params.lat,
      lon: params.lon,
    );
  }
}