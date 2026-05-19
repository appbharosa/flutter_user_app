import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/medicine_booking_response.dart';
import '../repositories/medicine_booking_repository.dart';



class BookMedicineParams {
  final int mainDataId;
  final String orderType;
  final int addressId;
  final List<String> imagePaths;
  BookMedicineParams({required this.mainDataId, required this.orderType, required this.addressId, required this.imagePaths});
}

class BookMedicineUseCase {
  final MedicineBookingRepository repository;
  BookMedicineUseCase(this.repository);
  Future<Either<Failure, String>> call(BookMedicineParams params) async {
    return await repository.bookMedicine(params);
  }
}