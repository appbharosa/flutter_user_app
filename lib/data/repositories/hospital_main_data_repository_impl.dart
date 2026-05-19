import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/hospital_main_data.dart';
import '../../domain/entities/hospital_doctor.dart';
import '../../domain/repositories/hospital_main_data_repository.dart';
import '../data_sources/hospital_main_data_remote_datasource.dart';


class HospitalMainDataRepositoryImpl implements HospitalMainDataRepository {
  final HospitalMainDataRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  HospitalMainDataRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, (HospitalMainData, List<HospitalDoctor>)>> getHospitalData(int mainDataId) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final (hospital, doctors) = await remoteDataSource.getHospitalData(mainDataId);
      return Right((hospital, doctors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}