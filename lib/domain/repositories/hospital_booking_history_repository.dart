
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_diagnostic_booking_item.dart';

abstract class HospitalBookingHistoryRepository {
  Future<Either<Failure, List<HospitalDiagnosticBookingItem>>> getOngoingBookings(String language);
  Future<Either<Failure, List<HospitalDiagnosticBookingItem>>> getCompletedBookings(String language);
}