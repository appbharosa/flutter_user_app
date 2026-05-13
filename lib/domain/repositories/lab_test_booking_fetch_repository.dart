import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_test_booking_fetch_item.dart';
import '../entities/lab_test_booking_fetch_detail.dart';



abstract class LabTestBookingFetchRepository {
  Future<Either<Failure, List<LabTestBookingFetchItem>>> getOngoingBookings({required int page, required int perPage});
  Future<Either<Failure, List<LabTestBookingFetchItem>>> getCompletedBookings({required int page, required int perPage});
  Future<Either<Failure, LabTestBookingFetchDetail>> getBookingDetail(String bookingId);
}