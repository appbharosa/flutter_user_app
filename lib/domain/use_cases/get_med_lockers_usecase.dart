import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker.dart';
import '../entities/med_locker_list_item.dart';
import '../repositories/med_locker_repository.dart';

//
// class GetMedLockersUseCase {
//   final MedLockerRepository repository;
//   GetMedLockersUseCase(this.repository);
//   Future<Either<Failure, List<MedLockerListItem>>> call() => repository.getMedLockers();
// }
//
// class AddMedLockerUseCase {
//   final MedLockerRepository repository;
//   AddMedLockerUseCase(this.repository);
//   Future<Either<Failure, MedLocker>> call(String name, List<File> images) =>
//       repository.addMedLocker(name, images);
// }