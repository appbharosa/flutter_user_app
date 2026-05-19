// lib/features/ambulance_booking/domain/repositories/ambulance_booking_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ambulance_booking.dart';

abstract class AmbulanceBookingRepository {
  Future<Either<Failure, AmbulanceBooking>> bookAmbulance({
    required String language,
    required int mainDataId,
  });
}