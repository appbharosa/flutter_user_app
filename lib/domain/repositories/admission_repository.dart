import '../entities/admission_request.dart';

abstract class AdmissionRepository {
  Future<void> submitAdmission(AdmissionRequest request);
}