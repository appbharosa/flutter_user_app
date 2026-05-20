import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_booking.dart';

abstract class BookDoctorUseCase {
  Future<Either<Failure, DoctorBookingResponse>> call({
    required int doctorId,
    required int slotId,
    required int familyMemberId,
    required int addressId,
    required String language,
  });
}