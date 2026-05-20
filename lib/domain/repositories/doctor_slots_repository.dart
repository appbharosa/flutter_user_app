import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_slot.dart';

abstract class DoctorSlotsRepository {
  Future<Either<Failure, DoctorSlotsResponse>> getDoctorSlots({
    required int doctorId,
    required String language,
    String? date,
  });
}