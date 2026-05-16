import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor_slots_response.dart';

abstract class OnlineDoctorSlotRepository {
  Future<Either<Failure, OnlineDoctorSlotsResponse>> getSlots(String date);
}