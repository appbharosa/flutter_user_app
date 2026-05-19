
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_booking_item.dart';

abstract class PharmacyBookingHistoryRepository {
  Future<Either<Failure, List<PharmacyBookingItem>>> getOngoingBookings(String language);
  Future<Either<Failure, List<PharmacyBookingItem>>> getCompletedBookings(String language);
}