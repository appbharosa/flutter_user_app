import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lab_slots_response.dart';
import '../../domain/repositories/lab_slot_repository.dart';
import '../data_sources/lab_slot_remote_datasource.dart';



class LabSlotRepositoryImpl implements LabSlotRepository {
  final LabSlotRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  LabSlotRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, LabSlotsResponse>> getSlots(String date) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final slots = await remoteDataSource.getSlots(date);
      print("✅ Repository: slots received");
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