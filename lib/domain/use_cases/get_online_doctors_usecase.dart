import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/online_doctor.dart';
import '../repositories/online_doctor_repository.dart';


class GetOnlineDoctorsParams {
  final int page;
  final int perPage;
  final String lang;
  final int? specialityId;
  GetOnlineDoctorsParams({
    required this.page,
    required this.perPage,
    required this.lang,
    this.specialityId,
  });
}

class GetOnlineDoctorsUseCase {
  final OnlineDoctorRepository repository;
  GetOnlineDoctorsUseCase(this.repository);
  Future<Either<Failure, List<OnlineDoctor>>> call(GetOnlineDoctorsParams params) async {
    return await repository.getDoctors(
      page: params.page,
      perPage: params.perPage,
      lang: params.lang,
      specialityId: params.specialityId,
    );
  }
}

class GetTotalPagesUseCase {
  final OnlineDoctorRepository repository;
  GetTotalPagesUseCase(this.repository);
  Future<Either<Failure, int>> call() => repository.getTotalPages();
}

class ClearDoctorCacheUseCase {
  final OnlineDoctorRepository repository;
  ClearDoctorCacheUseCase(this.repository);
  void call() => repository.clearCache();
}