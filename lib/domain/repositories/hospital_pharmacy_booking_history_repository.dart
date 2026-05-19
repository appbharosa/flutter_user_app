
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_pharmacy_booking_item.dart';

abstract class HospitalPharmacyBookingHistoryRepository {
  Future<Either<Failure, List<HospitalPharmacyBookingItem>>> getOngoingBookings(String language);
  Future<Either<Failure, List<HospitalPharmacyBookingItem>>> getCompletedBookings(String language);
}