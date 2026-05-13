import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_slots_response.dart';


abstract class LabSlotRepository {
  Future<Either<Failure, LabSlotsResponse>> getSlots(String date);
}