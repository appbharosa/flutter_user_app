import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital.dart';
import '../repositories/hospital_filtered_repository.dart';


class GetFilteredHospitalsParams {
  final String lang;
  final double lat;
  final double lon;
  final int catId;
  final String specialityIds;

  GetFilteredHospitalsParams({
    required this.lang,
    required this.lat,
    required this.lon,
    required this.catId,
    required this.specialityIds,
  });
}

class GetFilteredHospitalsUseCase {
  final HospitalFilteredRepository repository;
  GetFilteredHospitalsUseCase(this.repository);
  Future<Either<Failure, List<Hospital>>> call(GetFilteredHospitalsParams params) async {
    return await repository.getFilteredHospitals(
      lang: params.lang,
      lat: params.lat,
      lon: params.lon,
      catId: params.catId,
      specialityIds: params.specialityIds,
    );
  }
}