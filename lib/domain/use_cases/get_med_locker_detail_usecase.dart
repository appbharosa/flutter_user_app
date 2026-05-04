import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker.dart';
import '../repositories/med_locker_repository.dart';


class GetMedLockerDetailUseCase {
  final MedLockerRepository repository;
  GetMedLockerDetailUseCase(this.repository);
  Future<Either<Failure, MedLocker>> call(int id) async {
    return await repository.getMedLockerDetail(id);
  }
}