import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor.dart';

abstract class OnlineDoctorRepository {
  Future<Either<Failure, List<OnlineDoctor>>> getDoctors({
    required int page,
    required int perPage,
    required String lang,
    int? specialityId,
  });
  Future<Either<Failure, int>> getTotalPages();
  void clearCache(); // new
}
