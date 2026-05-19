
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_booking_item.dart';
import '../repositories/pharmacy_booking_history_repository.dart';

class GetPharmacyBookingsUseCase {
  final PharmacyBookingHistoryRepository repository;
  GetPharmacyBookingsUseCase(this.repository);

  Future<Either<Failure, List<PharmacyBookingItem>>> getOngoing(String language) async {
    return await repository.getOngoingBookings(language);
  }

  Future<Either<Failure, List<PharmacyBookingItem>>> getCompleted(String language) async {
    return await repository.getCompletedBookings(language);
  }
}