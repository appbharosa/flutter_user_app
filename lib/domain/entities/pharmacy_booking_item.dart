
class PharmacyBookingItem {
  final int id;
  final String bookingId;
  final String hospitalName;
  final String orderType;
  final String createdOn;
  final String bookingType;
  final String bookingStatus;
  final String image;
  final String acceptStatus;
  final List<dynamic> products;

  PharmacyBookingItem({
    required this.id,
    required this.bookingId,
    required this.hospitalName,
    required this.orderType,
    required this.createdOn,
    required this.bookingType,
    required this.bookingStatus,
    required this.image,
    required this.acceptStatus,
    required this.products,
  });
}