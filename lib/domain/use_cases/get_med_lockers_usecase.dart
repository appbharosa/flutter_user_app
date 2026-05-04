import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker.dart';
import '../repositories/med_locker_repository.dart';


class GetMedLockersUseCase {
  final MedLockerRepository repository;
  GetMedLockersUseCase(this.repository);
  Future<Either<Failure, List<MedLocker>>> call() async {
    return await repository.getMedLockers();
  }
}