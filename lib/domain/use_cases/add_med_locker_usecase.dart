import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker.dart';
import '../repositories/med_locker_repository.dart';

class AddMedLockerParams {
  final String name;
  final List<String> imagePaths;
  AddMedLockerParams({required this.name, required this.imagePaths});
}

class AddMedLockerUseCase {
  final MedLockerRepository repository;
  AddMedLockerUseCase(this.repository);
  Future<Either<Failure, MedLocker>> call(AddMedLockerParams params) async {
    return await repository.addMedLocker(
      name: params.name,
      imagePaths: params.imagePaths,
    );
  }
}