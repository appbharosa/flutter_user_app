import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/diagnostic_booking_fetch_item.dart';
import '../../domain/entities/diagnostic_booking_fetch_detail.dart';
import '../../domain/repositories/diagnostic_booking_fetch_repository.dart';
import '../data_sources/diagnostic_booking_fetch_remote_datasource.dart';



class DiagnosticBookingFetchRepositoryImpl implements DiagnosticBookingFetchRepository {
  final DiagnosticBookingFetchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  DiagnosticBookingFetchRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<DiagnosticBookingFetchItem>>> getOngoingBookings({required int page, required int perPage}) async {
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
  Future<Either<Failure, List<DiagnosticBookingFetchItem>>> getCompletedBookings({required int page, required int perPage}) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final items = await remoteDataSource.getCompletedBookings(page, perPage);
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
  Future<Either<Failure, DiagnosticBookingFetchDetail>> getBookingDetail(String bookingId) async {
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