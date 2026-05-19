class HospitalDiagnosticBooking {
  final int mainDataId;
  final int addressId;
  final List<String> imagePaths;
  final int familyMemberId;
  final String language;

  HospitalDiagnosticBooking({
    required this.mainDataId,
    required this.addressId,
    required this.imagePaths,
    required this.familyMemberId,
    required this.language,
  });
}