import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital.dart';


abstract class HospitalRepository {
  Future<Either<Failure, List<Hospital>>> getHospitals({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });
}