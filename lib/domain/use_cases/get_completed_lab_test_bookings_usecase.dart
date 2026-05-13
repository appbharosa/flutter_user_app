import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/lab_test_booking_fetch_item.dart';
import '../repositories/lab_test_booking_fetch_repository.dart';


class GetCompletedLabTestBookingsParams {
  final int page;
  final int perPage;
  GetCompletedLabTestBookingsParams({required this.page, required this.perPage});
}

class GetCompletedLabTestBookingsUseCase {
  final LabTestBookingFetchRepository repository;
  GetCompletedLabTestBookingsUseCase(this.repository);
  Future<Either<Failure, List<LabTestBookingFetchItem>>> call(GetCompletedLabTestBookingsParams params) async {
    print("🎯 UseCase: GetCompletedLabTestBookingsUseCase called with page=${params.page}");
    return await repository.getCompletedBookings(page: params.page, perPage: params.perPage);
  }
}