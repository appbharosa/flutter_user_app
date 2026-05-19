import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/hospital_main_data.dart';
import '../entities/hospital_doctor.dart';
import '../repositories/hospital_main_data_repository.dart';

class GetHospitalMainDataUseCase {
  final HospitalMainDataRepository repository;
  GetHospitalMainDataUseCase(this.repository);
  Future<Either<Failure, (HospitalMainData, List<HospitalDoctor>)>> call(int mainDataId) async {
    return await repository.getHospitalData(mainDataId);
  }
}