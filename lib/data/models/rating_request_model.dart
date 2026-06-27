class RatingRequestModel {
  final String doctorId;
  final String bookingId;
  final String mainDataId;
  final int rating;
  final String message;

  RatingRequestModel({
    required this.doctorId,
    required this.bookingId,
    required this.mainDataId,
    required this.rating,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'booking_id': bookingId,
    'main_data_id': mainDataId,
    'rating': rating,
    'message': message,
  };
}