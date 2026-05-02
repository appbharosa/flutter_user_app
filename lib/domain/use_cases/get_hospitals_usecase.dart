import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital.dart';
import '../repositories/hospital_repository.dart';


class GetHospitalsParams {
  final int page;
  final int perPage;
  final String lang;
  final double lat;
  final double lon;

  GetHospitalsParams({
    required this.page,
    required this.perPage,
    required this.lang,
    required this.lat,
    required this.lon,
  });
}

class GetHospitalsUseCase {
  final HospitalRepository repository;

  GetHospitalsUseCase(this.repository);

  Future<Either<Failure, List<Hospital>>> call(GetHospitalsParams params) async {
    return await repository.getHospitals(
      page: params.page,
      perPage: params.perPage,
      lang: params.lang,
      lat: params.lat,
      lon: params.lon,
    );
  }
}