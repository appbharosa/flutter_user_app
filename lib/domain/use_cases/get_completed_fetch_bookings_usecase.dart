import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/diagnostic_booking_fetch_item.dart';
import '../repositories/diagnostic_booking_repository.dart';
import '../repositories/diagnostic_booking_fetch_repository.dart';


class GetCompletedFetchBookingsParams {
  final int page;
  final int perPage;
  GetCompletedFetchBookingsParams({required this.page, required this.perPage});
}

class GetCompletedFetchBookingsUseCase {
  final DiagnosticBookingFetchRepository repository;
  GetCompletedFetchBookingsUseCase(this.repository);
  Future<Either<Failure, List<DiagnosticBookingFetchItem>>> call(GetCompletedFetchBookingsParams params) async {
    return await repository.getOngoingBookings(page: params.page, perPage: params.perPage);
  }
}