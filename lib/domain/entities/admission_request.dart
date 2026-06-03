class AdmissionRequest {
  final String patientName;
  final int age;
  final String gender;
  final String phone;
  final String symptoms;
  final String departmentRequired;
  final String admissionType;
  final String preferredLocation;
  final List<String> prescriptionPaths;
  final List<String> reportsPaths;
  final List<String> insuranceCardPaths;

  AdmissionRequest({
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.symptoms,
    required this.departmentRequired,
    required this.admissionType,
    required this.preferredLocation,
    this.prescriptionPaths = const [],
    this.reportsPaths = const [],
    this.insuranceCardPaths = const [],
  });
}