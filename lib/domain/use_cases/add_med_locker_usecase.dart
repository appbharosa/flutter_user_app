import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker.dart';
import '../entities/med_locker_add_response.dart';
import '../entities/med_locker_detail.dart';
import '../entities/med_locker_list_item.dart';
import '../repositories/med_locker_repository.dart';

class GetMedLockersUseCase {
  final MedLockerRepository repository;
  GetMedLockersUseCase(this.repository);
  Future<Either<Failure, List<MedLockerListItem>>> call() => repository.getMedLockers();
}

class GetMedLockerDetailUseCase {
  final MedLockerRepository repository;
  GetMedLockerDetailUseCase(this.repository);
  Future<Either<Failure, MedLockerDetail>> call(int id) => repository.getMedLockerDetail(id);
}

class AddMedLockerUseCase {
  final MedLockerRepository repository;
  AddMedLockerUseCase(this.repository);
  Future<Either<Failure, MedLockerAddResponse>> call(String name, List<File> images) =>
      repository.addMedLocker(name, images);
}