
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_diagnostic_booking_item.dart';
import '../repositories/hospital_booking_history_repository.dart';

class GetHospitalDiagnosticBookingsUseCase {
  final HospitalBookingHistoryRepository repository;

  GetHospitalDiagnosticBookingsUseCase(this.repository);

  Future<Either<Failure, List<HospitalDiagnosticBookingItem>>> getOngoing(String language) async {
    return await repository.getOngoingBookings(language);
  }

  Future<Either<Failure, List<HospitalDiagnosticBookingItem>>> getCompleted(String language) async {
    return await repository.getCompletedBookings(language);
  }
}