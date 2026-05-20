import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_slot.dart';
import '../repositories/doctor_slots_repository.dart';

class GetDoctorSlotsUseCase {
  final DoctorSlotsRepository repository;
  GetDoctorSlotsUseCase(this.repository);

  Future<Either<Failure, DoctorSlotsResponse>> call({
    required int doctorId,
    required String language,
    String? date,
  }) async {
    return await repository.getDoctorSlots(doctorId: doctorId, language: language,date: date);
  }
}