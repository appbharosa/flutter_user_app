
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ambulance_booking.dart';
import '../../domain/repositories/ambulance_booking_repository.dart';
import '../data_sources/ambulance_booking_remote_datasource.dart';


class AmbulanceBookingRepositoryImpl implements AmbulanceBookingRepository {
  final AmbulanceBookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AmbulanceBookingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AmbulanceBooking>> bookAmbulance({
    required String language,
    required int mainDataId,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final booking = await remoteDataSource.bookAmbulance(
        language: language,
        mainDataId: mainDataId,
      );
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}