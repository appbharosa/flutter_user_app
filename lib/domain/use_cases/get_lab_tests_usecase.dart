import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_test.dart';
import '../repositories/lab_test_repository.dart';

class GetLabTestsParams {
  final int page;
  final int perPage;
  final String lang;
  final double lat;
  final double lon;

  GetLabTestsParams({
    required this.page,
    required this.perPage,
    required this.lang,
    required this.lat,
    required this.lon,
  });
}

class GetLabTestsUseCase {
  final LabTestRepository repository;

  GetLabTestsUseCase(this.repository);

  Future<Either<Failure, List<LabTest>>> call(GetLabTestsParams params) async {
    return await repository.getLabTests(
      page: params.page,
      perPage: params.perPage,
      lang: params.lang,
      lat: params.lat,
      lon: params.lon,
    );
  }
}