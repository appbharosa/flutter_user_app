import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/booking_response.dart';
import '../../domain/repositories/diagnostic_booking_repository.dart';
import '../data_sources/diagnostic_booking_remote_datasource.dart';

class DiagnosticBookingRepositoryImpl implements DiagnosticBookingRepository {
  final DiagnosticBookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  DiagnosticBookingRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, BookingResponse>> bookDiagnostic({
    required int diagnosticId,
    required List<String> prescriptionPaths,
    required String lang,
    required int familyMemberId,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final files = prescriptionPaths.map((p) => File(p)).toList();
      final response = await remoteDataSource.bookDiagnostic(
        diagnosticId: diagnosticId,
        prescriptionFiles: files,
        lang: lang,
        familyMemberId: familyMemberId,
      );
      print("📦 Diagnostic Booking Request:");
      print("   diagnostic_id: $diagnosticId (${diagnosticId.runtimeType})");
      print("   language: $lang");
      print("   family_member_id: $familyMemberId (${familyMemberId.runtimeType})");
      print("   number of files: ${prescriptionPaths}");
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}