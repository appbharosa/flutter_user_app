import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor_speciality.dart';


abstract class OnlineDoctorSpecialityRepository {
  Future<Either<Failure, List<OnlineDoctorSpeciality>>> getSpecialities(String lang);
}