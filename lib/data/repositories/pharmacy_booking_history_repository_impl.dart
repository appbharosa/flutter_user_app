
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/pharmacy_booking_item.dart';
import '../../domain/repositories/pharmacy_booking_history_repository.dart';
import '../data_sources/pharmacy_booking_history_remote_datasource.dart';

class PharmacyBookingHistoryRepositoryImpl implements PharmacyBookingHistoryRepository {
  final PharmacyBookingHistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PharmacyBookingHistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PharmacyBookingItem>>> getOngoingBookings(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final bookings = await remoteDataSource.getOngoingBookings(language);
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyBookingItem>>> getCompletedBookings(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final bookings = await remoteDataSource.getCompletedBookings(language);
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}