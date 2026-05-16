import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor_speciality.dart';
import '../repositories/online_doctor_speciality_repository.dart';

class GetOnlineDoctorSpecialitiesUseCase {
  final OnlineDoctorSpecialityRepository repository;
  GetOnlineDoctorSpecialitiesUseCase(this.repository);
  Future<Either<Failure, List<OnlineDoctorSpeciality>>> call(String lang) async {
    return await repository.getSpecialities(lang);
  }
}