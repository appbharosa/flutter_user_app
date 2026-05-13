import 'package:dartz/dartz.dart';
import 'package:user/domain/repositories/lab_test_booking_fetch_repository.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_test_booking_fetch_item.dart';
import '../repositories/lab_test_booking_repository.dart';




class GetOngoingLabTestBookingsParams {
  final int page;
  final int perPage;
  GetOngoingLabTestBookingsParams({required this.page, required this.perPage});
}

class GetOngoingLabTestBookingsUseCase {
  final LabTestBookingFetchRepository repository;
  GetOngoingLabTestBookingsUseCase(this.repository);
  Future<Either<Failure, List<LabTestBookingFetchItem>>> call(GetOngoingLabTestBookingsParams params) async {
    return await repository.getOngoingBookings(page: params.page, perPage: params.perPage);
  }
}