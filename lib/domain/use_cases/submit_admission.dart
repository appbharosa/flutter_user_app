import '../entities/admission_request.dart';
import '../repositories/admission_repository.dart';

class SubmitAdmission {
  final AdmissionRepository repository;

  SubmitAdmission(this.repository);

  Future<void> call(AdmissionRequest request) {
    return repository.submitAdmission(request);
  }
}