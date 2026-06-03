import '../../domain/entities/admission_request.dart';
import '../../domain/repositories/admission_repository.dart';
import '../data_sources/admission_remote_datasource.dart';

class AdmissionRepositoryImpl implements AdmissionRepository {
  final AdmissionRemoteDataSource remoteDataSource;

  AdmissionRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitAdmission(AdmissionRequest request) {
    return remoteDataSource.requestAdmission(request);
  }
}