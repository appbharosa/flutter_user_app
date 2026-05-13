import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_slots_response.dart';
import '../repositories/lab_slot_repository.dart';

class GetLabSlotsUseCase {
  final LabSlotRepository repository;
  GetLabSlotsUseCase(this.repository);
  Future<Either<Failure, LabSlotsResponse>> call(String date) async {
    return await repository.getSlots(date);
  }
}