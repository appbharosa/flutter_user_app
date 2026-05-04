import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker.dart';


abstract class MedLockerRepository {
  Future<Either<Failure, List<MedLocker>>> getMedLockers();
  Future<Either<Failure, MedLocker>> getMedLockerDetail(int id);
  Future<Either<Failure, MedLocker>> addMedLocker({
    required String name,
    required List<String> imagePaths, // local file paths
  });
}