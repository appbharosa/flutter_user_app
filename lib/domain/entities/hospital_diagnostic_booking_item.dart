
class HospitalDiagnosticBookingItem {
  final int id;
  final String bookingId;
  final String createdOn;
  final int userId;
  final int diagnosticId;
  final String name;
  final String logo;
  final String openTime;
  final String closeTime;
  final String location;
  final int slotId;
  final String date;
  final String time;
  final String bookingStatus;
  final String bookingType;
  final Map<String, dynamic> packages;

  HospitalDiagnosticBookingItem({
    required this.id,
    required this.bookingId,
    required this.createdOn,
    required this.userId,
    required this.diagnosticId,
    required this.name,
    required this.logo,
    required this.openTime,
    required this.closeTime,
    required this.location,
    required this.slotId,
    required this.date,
    required this.time,
    required this.bookingStatus,
    required this.bookingType,
    required this.packages,
  });
}