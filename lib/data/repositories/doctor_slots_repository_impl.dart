
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/doctor_slot.dart';
import '../../domain/repositories/doctor_slots_repository.dart';
import '../data_sources/doctor_slots_remote_datasource.dart';

class DoctorSlotsRepositoryImpl implements DoctorSlotsRepository {
  final DoctorSlotsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DoctorSlotsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DoctorSlotsResponse>> getDoctorSlots({
    required int doctorId,
    required String language,
    String? date,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final slots = await remoteDataSource.getDoctorSlots(doctorId: doctorId, language: language,);
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}