import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/diagnostic_booking_fetch_detail.dart';
import '../repositories/diagnostic_booking_repository.dart';
import '../repositories/diagnostic_booking_fetch_repository.dart';



class GetBookingFetchDetailUseCase {
  final DiagnosticBookingFetchRepository repository;
  GetBookingFetchDetailUseCase(this.repository);
  Future<Either<Failure, DiagnosticBookingFetchDetail>> call(String bookingId) async {
    return await repository.getBookingDetail(bookingId);
  }
}