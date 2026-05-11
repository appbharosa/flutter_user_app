import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/booking_response.dart';

abstract class DiagnosticBookingRepository {
  Future<Either<Failure, BookingResponse>> bookDiagnostic({
    required int diagnosticId,
    required List<String> prescriptionPaths,
    required String lang,
    required int familyMemberId,
  });
}