
class HospitalPharmacyBookingItem {
  final int id;
  final String bookingId;
  final String orderType;
  final String createdOn;
  final String bookingType;
  final String bookingStatus;
  final String image;
  final String acceptStatus;
  final String logo;
  final String location;
  final String hospitalName;

  HospitalPharmacyBookingItem({
    required this.id,
    required this.bookingId,
    required this.orderType,
    required this.createdOn,
    required this.bookingType,
    required this.bookingStatus,
    required this.image,
    required this.acceptStatus,
    required this.logo,
    required this.location,
    required this.hospitalName,
  });
}