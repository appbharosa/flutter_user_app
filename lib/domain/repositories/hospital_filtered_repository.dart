import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital.dart';

abstract class HospitalFilteredRepository {
  Future<Either<Failure, List<Hospital>>> getFilteredHospitals({
    required String lang,
    required double lat,
    required double lon,
    required int catId,
    required String specialityIds,
  });
}