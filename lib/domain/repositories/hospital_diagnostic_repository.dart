import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital_diagnostic_booking.dart';


abstract class HospitalDiagnosticRepository {
  Future<Either<Failure, String>> bookDiagnostic(HospitalDiagnosticBooking booking);
}