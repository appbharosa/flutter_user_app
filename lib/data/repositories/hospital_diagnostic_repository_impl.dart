import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/hospital_diagnostic_booking.dart';
import '../../domain/repositories/hospital_diagnostic_repository.dart';
import '../data_sources/hospital_diagnostic_remote_datasource.dart';

class HospitalDiagnosticRepositoryImpl implements HospitalDiagnosticRepository {
  final HospitalDiagnosticRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HospitalDiagnosticRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> bookDiagnostic(HospitalDiagnosticBooking booking) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final message = await remoteDataSource.bookDiagnostic(booking);
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