import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/free_lab_package.dart';
import '../entities/free_lab_slot.dart';

abstract class FreeLabRepository {
  Future<Either<Failure, List<FreeLabPackage>>> getFreeLabPackages(String language);
  Future<Either<Failure, FreeLabSlotResponse>> getFreeLabSlots(String language, int packageId);
}