import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_test.dart';

abstract class LabTestRepository {
  Future<Either<Failure, List<LabTest>>> getLabTests({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });
}