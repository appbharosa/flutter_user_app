import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lab_test_booking_fetch_item.dart';
import '../../domain/entities/lab_test_booking_fetch_detail.dart';
import '../../domain/repositories/lab_test_booking_fetch_repository.dart';
import '../data_sources/lab_test_booking_fetch_remote_datasource.dart';

class LabTestBookingFetchRepositoryImpl implements LabTestBookingFetchRepository {
  final LabTestBookingFetchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  LabTestBookingFetchRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<LabTestBookingFetchItem>>> getOngoingBookings({required int page, required int perPage}) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final items = await remoteDataSource.getOngoingBookings(page, perPage);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override

  Future<Either<Failure, List<LabTestBookingFetchItem>>> getCompletedBookings({required int page, required int perPage}) async {
    print("🏛️ Repository: getCompletedBookings called");
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final items = await remoteDataSource.getCompletedBookings(page, perPage);
      print("🏛️ Repository: received ${items.length} items");
      return Right(items);
    } catch (e) {
      print("🏛️ Repository error: $e");
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, LabTestBookingFetchDetail>> getBookingDetail(String bookingId) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final detail = await remoteDataSource.getBookingDetail(bookingId);
      return Right(detail);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}