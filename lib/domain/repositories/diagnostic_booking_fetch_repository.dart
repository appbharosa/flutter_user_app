import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/diagnostic_booking_fetch_item.dart';
import '../entities/diagnostic_booking_fetch_detail.dart';


abstract class DiagnosticBookingFetchRepository {
  Future<Either<Failure, List<DiagnosticBookingFetchItem>>> getOngoingBookings({required int page, required int perPage});
  Future<Either<Failure, List<DiagnosticBookingFetchItem>>> getCompletedBookings({required int page, required int perPage});
  Future<Either<Failure, DiagnosticBookingFetchDetail>> getBookingDetail(String bookingId);
}