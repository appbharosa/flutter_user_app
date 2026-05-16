import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/online_doctor_speciality.dart';
import '../../domain/repositories/online_doctor_speciality_repository.dart';
import '../data_sources/online_doctor_speciality_remote_datasource.dart';

class OnlineDoctorSpecialityRepositoryImpl implements OnlineDoctorSpecialityRepository {
  final OnlineDoctorSpecialityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  OnlineDoctorSpecialityRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<OnlineDoctorSpeciality>>> getSpecialities(String lang) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final specialities = await remoteDataSource.getSpecialities(lang);
      return Right(specialities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}