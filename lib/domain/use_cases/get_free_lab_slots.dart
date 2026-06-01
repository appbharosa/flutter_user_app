import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/free_lab_slot.dart';
import '../repositories/free_lab_repository.dart';

class GetFreeLabSlotsUseCase {
  final FreeLabRepository repository;
  GetFreeLabSlotsUseCase(this.repository);

  Future<Either<Failure, FreeLabSlotResponse>> call(String language, int packageId) async {
    return await repository.getFreeLabSlots(language, packageId);
  }
}