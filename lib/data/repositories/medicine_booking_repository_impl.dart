import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/medicine_booking_response.dart';
import '../../domain/repositories/medicine_booking_repository.dart';
import '../../domain/use_cases/book_medicine_usecase.dart';
import '../data_sources/medicine_booking_remote_datasource.dart';



class MedicineBookingRepositoryImpl implements MedicineBookingRepository {
  final MedicineBookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  MedicineBookingRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, String>> bookMedicine(BookMedicineParams params) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final files = params.imagePaths.map((p) => File(p)).toList();
      final message = await remoteDataSource.bookMedicine(
        mainDataId: params.mainDataId,
        orderType: params.orderType,
        addressId: params.addressId,
        imagePaths: params.imagePaths,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}