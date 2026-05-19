
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_doctor_booking_item.dart';

abstract class HospitalDoctorBookingHistoryRepository {
  Future<Either<Failure, List<HospitalDoctorBookingItem>>> getActiveBookings(String language);
  Future<Either<Failure, List<HospitalDoctorBookingItem>>> getCompletedBookings(String language);
}