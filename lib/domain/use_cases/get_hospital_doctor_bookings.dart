
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_doctor_booking_item.dart';
import '../repositories/hospital_doctor_booking_history_repository.dart';

class GetHospitalDoctorBookingsUseCase {
  final HospitalDoctorBookingHistoryRepository repository;
  GetHospitalDoctorBookingsUseCase(this.repository);

  Future<Either<Failure, List<HospitalDoctorBookingItem>>> getActive(String language) async {
    return await repository.getActiveBookings(language);
  }

  Future<Either<Failure, List<HospitalDoctorBookingItem>>> getCompleted(String language) async {
    return await repository.getCompletedBookings(language);
  }
}