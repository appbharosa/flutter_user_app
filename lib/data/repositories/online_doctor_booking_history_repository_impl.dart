
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/online_doctor_booking_item.dart';
import '../../domain/repositories/online_doctor_booking_history_repository.dart';
import '../data_sources/online_doctor_booking_history_remote_datasource.dart';

class OnlineDoctorBookingHistoryRepositoryImpl implements OnlineDoctorBookingHistoryRepository {
  final OnlineDoctorBookingHistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OnlineDoctorBookingHistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OnlineDoctorBookingItem>>> getActiveBookings(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final bookings = await remoteDataSource.getActiveBookings(language);
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
  Future<Either<Failure, List<OnlineDoctorBookingItem>>> getCompletedBookings(String language) async {
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