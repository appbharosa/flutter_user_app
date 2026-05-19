// lib/features/ambulance_booking/domain/usecases/book_ambulance.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ambulance_booking.dart';
import '../repositories/ambulance_booking_repository.dart';

class BookAmbulanceUseCase {
  final AmbulanceBookingRepository repository;
  BookAmbulanceUseCase(this.repository);

  Future<Either<Failure, AmbulanceBooking>> call({
    required String language,
    required int mainDataId,
  }) async {
    return await repository.bookAmbulance(language: language, mainDataId: mainDataId);
  }
}