import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital_main_data.dart';
import '../entities/hospital_doctor.dart';
abstract class HospitalMainDataRepository {
  Future<Either<Failure, (HospitalMainData, List<HospitalDoctor>)>> getHospitalData({
    required int mainDataId,
    required String lang,
  });
}