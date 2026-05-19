import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/medicine_booking_response.dart';
import '../use_cases/book_medicine_usecase.dart';


abstract class MedicineBookingRepository {
  Future<Either<Failure, String>> bookMedicine(BookMedicineParams params);
}