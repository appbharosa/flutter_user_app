// lib/features/hospital_diagnostic/domain/usecases/book_hospital_diagnostic.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hospital_diagnostic_booking.dart';
import '../repositories/hospital_diagnostic_repository.dart';

class BookHospitalDiagnosticUseCase {
  final HospitalDiagnosticRepository repository;
  BookHospitalDiagnosticUseCase(this.repository);

  Future<Either<Failure, String>> call(HospitalDiagnosticBooking params) async {
    return await repository.bookDiagnostic(params);
  }
}