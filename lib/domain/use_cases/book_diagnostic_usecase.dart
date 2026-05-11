import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/booking_response.dart';
import '../repositories/diagnostic_booking_repository.dart';

class BookDiagnosticParams {
  final int diagnosticId;
  final List<String> prescriptionPaths;
  final String lang;
  final int familyMemberId;
  BookDiagnosticParams({required this.diagnosticId, required this.prescriptionPaths, required this.lang, required this.familyMemberId});
}

class BookDiagnosticUseCase {
  final DiagnosticBookingRepository repository;
  BookDiagnosticUseCase(this.repository);
  Future<Either<Failure, BookingResponse>> call(BookDiagnosticParams params) async {
    return await repository.bookDiagnostic(
      diagnosticId: params.diagnosticId,
      prescriptionPaths: params.prescriptionPaths,
      lang: params.lang,
      familyMemberId: params.familyMemberId,
    );
  }
}