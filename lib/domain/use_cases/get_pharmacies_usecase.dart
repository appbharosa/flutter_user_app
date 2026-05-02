import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pharmacy.dart';
import '../repositories/pharmacy_repository.dart';


class GetPharmaciesParams {
  final int page;
  final int perPage;
  final String lang;
  final double lat;
  final double lon;

  GetPharmaciesParams({
    required this.page,
    required this.perPage,
    required this.lang,
    required this.lat,
    required this.lon,
  });
}

class GetPharmaciesUseCase {
  final PharmacyRepository repository;

  GetPharmaciesUseCase(this.repository);

  Future<Either<Failure, List<Pharmacy>>> call(GetPharmaciesParams params) async {
    return await repository.getPharmacies(
      page: params.page,
      perPage: params.perPage,
      lang: params.lang,
      lat: params.lat,
      lon: params.lon,
    );
  }
}