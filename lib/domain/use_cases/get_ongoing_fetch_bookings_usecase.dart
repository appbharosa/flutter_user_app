import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/diagnostic_booking_fetch_item.dart';
import '../repositories/diagnostic_booking_repository.dart';
import '../repositories/diagnostic_booking_fetch_repository.dart';




class GetOngoingFetchBookingsParams {
  final int page;
  final int perPage;
  GetOngoingFetchBookingsParams({required this.page, required this.perPage});
}

class GetOngoingFetchBookingsUseCase {
  final DiagnosticBookingFetchRepository repository;
  GetOngoingFetchBookingsUseCase(this.repository);
  Future<Either<Failure, List<DiagnosticBookingFetchItem>>> call(GetOngoingFetchBookingsParams params) async {
    return await repository.getOngoingBookings(page: params.page, perPage: params.perPage);
  }
}