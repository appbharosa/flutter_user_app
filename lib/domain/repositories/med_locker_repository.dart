import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/med_locker_add_response.dart';
import '../entities/med_locker_detail.dart';
import '../entities/med_locker_list_item.dart';


abstract class MedLockerRepository {
  Future<Either<Failure, List<MedLockerListItem>>> getMedLockers();
  Future<Either<Failure, MedLockerDetail>> getMedLockerDetail(int id);
  Future<Either<Failure, MedLockerAddResponse>> addMedLocker(String name, List<File> images);
}