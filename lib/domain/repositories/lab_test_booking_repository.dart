import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/booking_response.dart';

// abstract class LabTestBookingRepository {
//   Future<Either<Failure, BookingResponse>> bookLabTest({
//     required int labTestId,
//     required List<String> prescriptionPaths,
//     required String lang,
//     required int familyMemberId,
//   });
// }

abstract class LabTestBookingRepository {
  Future<Either<Failure, BookingResponse>> bookLabTest({
    required int labTestId,
    required List<String> prescriptionPaths,
    required String lang,
    required int familyMemberId,
    // required int slotId,
    // required int packageId,
    // required int personsCount,
  });
}