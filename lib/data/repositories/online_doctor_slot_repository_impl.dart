import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/online_doctor_slots_response.dart';
import '../../domain/repositories/online_doctor_slot_repository.dart';
import '../data_sources/online_doctor_slot_remote_datasource.dart';

class OnlineDoctorSlotRepositoryImpl implements OnlineDoctorSlotRepository {
  final OnlineDoctorSlotRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  OnlineDoctorSlotRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, OnlineDoctorSlotsResponse>> getSlots(String date) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final slots = await remoteDataSource.getSlots(date);
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}