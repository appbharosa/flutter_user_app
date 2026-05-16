import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor_slots_response.dart';
import '../repositories/online_doctor_slot_repository.dart';

class GetOnlineDoctorSlotsUseCase {
  final OnlineDoctorSlotRepository repository;
  GetOnlineDoctorSlotsUseCase(this.repository);
  Future<Either<Failure, OnlineDoctorSlotsResponse>> call(String date) async {
    return await repository.getSlots(date);
  }
}