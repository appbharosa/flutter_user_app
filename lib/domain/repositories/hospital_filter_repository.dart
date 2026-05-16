import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital_filter_category.dart';

abstract class HospitalFilterRepository {
  Future<Either<Failure, List<HospitalFilterCategory>>> getFilters();
}