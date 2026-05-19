
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/online_doctor_booking_item.dart';
import '../repositories/online_doctor_booking_history_repository.dart';

class GetOnlineDoctorBookingsUseCase {
  final OnlineDoctorBookingHistoryRepository repository;
  GetOnlineDoctorBookingsUseCase(this.repository);

  Future<Either<Failure, List<OnlineDoctorBookingItem>>> getActive(String language) async {
    return await repository.getActiveBookings(language);
  }

  Future<Either<Failure, List<OnlineDoctorBookingItem>>> getCompleted(String language) async {
    return await repository.getCompletedBookings(language);
  }
}