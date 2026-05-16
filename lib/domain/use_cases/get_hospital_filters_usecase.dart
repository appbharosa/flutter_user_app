import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital_filter_category.dart';
import '../repositories/hospital_filter_repository.dart';

class GetHospitalFiltersUseCase {
  final HospitalFilterRepository repository;
  GetHospitalFiltersUseCase(this.repository);
  Future<Either<Failure, List<HospitalFilterCategory>>> call() async {
    return await repository.getFilters();
  }
}