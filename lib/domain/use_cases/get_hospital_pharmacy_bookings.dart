
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_pharmacy_booking_item.dart';
import '../repositories/hospital_pharmacy_booking_history_repository.dart';

class GetHospitalPharmacyBookingsUseCase {
  final HospitalPharmacyBookingHistoryRepository repository;
  GetHospitalPharmacyBookingsUseCase(this.repository);

  Future<Either<Failure, List<HospitalPharmacyBookingItem>>> getOngoing(String language) async {
    return await repository.getOngoingBookings(language);
  }

  Future<Either<Failure, List<HospitalPharmacyBookingItem>>> getCompleted(String language) async {
    return await repository.getCompletedBookings(language);
  }
}