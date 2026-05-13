import 'package:dartz/dartz.dart';
import 'package:user/domain/repositories/lab_test_booking_fetch_repository.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_test_booking_fetch_detail.dart';

class GetLabTestBookingDetailUseCase {
  final LabTestBookingFetchRepository repository;
  GetLabTestBookingDetailUseCase(this.repository);
  Future<Either<Failure, LabTestBookingFetchDetail>> call(String bookingId) async {
    return await repository.getBookingDetail(bookingId);
  }
}