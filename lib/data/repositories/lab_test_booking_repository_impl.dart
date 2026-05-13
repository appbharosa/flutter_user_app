import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/booking_response.dart';
import '../../domain/repositories/lab_test_booking_repository.dart';
import '../data_sources/lab_test_booking_remote_datasource.dart';

class LabTestBookingRepositoryImpl implements LabTestBookingRepository {
  final LabTestBookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  LabTestBookingRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, BookingResponse>> bookLabTest({
    required int labTestId,
    required List<String> prescriptionPaths,
    required String lang,
    required int familyMemberId,
    // required int slotId,
    // required int packageId,
    // required int personsCount,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final files = prescriptionPaths.map((p) => File(p)).toList();
      final response = await remoteDataSource.bookLabTest(
        labTestId: labTestId,
        prescriptionFiles: files,
        lang: lang,
        familyMemberId: familyMemberId,
        // slotId: slotId,
        // packageId: packageId,
        // personsCount: personsCount,
      );
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