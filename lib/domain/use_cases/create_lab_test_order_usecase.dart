import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/booking_response.dart';
import '../repositories/lab_test_booking_repository.dart';

// lib/domain/usecases/create_lab_test_order_usecase.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/booking_response.dart';
import '../repositories/lab_test_booking_repository.dart';

class CreateLabTestOrderParams {
  final int labTestId;
  final List<String> prescriptionPaths;
  final String lang;
  final int familyMemberId;
  // final int slotId;
  // final int packageId;
  // final int personsCount;

  CreateLabTestOrderParams({
    required this.labTestId,
    required this.prescriptionPaths,
    required this.lang,
    required this.familyMemberId,
    // required this.slotId,
    // required this.packageId,
    // required this.personsCount,
  });
}

class CreateLabTestOrderUseCase {
  final LabTestBookingRepository repository;
  CreateLabTestOrderUseCase(this.repository);
  Future<Either<Failure, BookingResponse>> call(CreateLabTestOrderParams params) async {
    return await repository.bookLabTest(
      labTestId: params.labTestId,
      prescriptionPaths: params.prescriptionPaths,
      lang: params.lang,
      familyMemberId: params.familyMemberId,
      // slotId: params.slotId,
      // packageId: params.packageId,
      // personsCount: params.personsCount,
    );
  }
}