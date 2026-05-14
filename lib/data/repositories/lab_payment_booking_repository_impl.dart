import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lab_payment_booking_response.dart';
import '../../domain/repositories/lab_payment_booking_repository.dart';
import '../data_sources/lab_payment_booking_remote_datasource.dart';



class LabPaymentBookingRepositoryImpl implements LabPaymentBookingRepository {
  final LabPaymentBookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  LabPaymentBookingRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, LabPaymentBookingResponse>> book({
    required int labTestId,
    required int testId,
    required int addressId,
    required int count,
    required double fee,
    required String date,
    required String time,
    required int familyMemberId,           // ✅ single integer
    int? couponId,
    required String paymentType,
    required List<String> prescriptionPaths,
    required int slotId,
    double consultationFee = 0,
    double flatDiscount = 0,
    String? orderId,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      // Convert paths to File objects
      final prescriptionFiles = prescriptionPaths.map((p) => File(p)).toList();

      final response = await remoteDataSource.book(
        labTestId: labTestId,
        testId: testId,
        addressId: addressId,
        count: count,
        fee: fee,
        date: date,
        time: time,
        familyMemberId: familyMemberId,
        couponId: couponId,
        paymentType: paymentType,
        prescriptionFiles: prescriptionFiles,
        slotId: slotId,
        consultationFee: consultationFee,
        flatDiscount: flatDiscount,
        orderId: orderId,
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