
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/online_doctor_booking_item.dart';

abstract class OnlineDoctorBookingHistoryRepository {
  Future<Either<Failure, List<OnlineDoctorBookingItem>>> getActiveBookings(String language);
  Future<Either<Failure, List<OnlineDoctorBookingItem>>> getCompletedBookings(String language);
}