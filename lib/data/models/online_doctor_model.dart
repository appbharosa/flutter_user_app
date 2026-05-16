import '../../domain/entities/online_doctor.dart';

class OnlineDoctorModel extends OnlineDoctor {
  const OnlineDoctorModel({
    required super.id,
    required super.name,
    required super.image,
    required super.fee,
    required super.availability,
    required super.qualification,
    required super.specialization,
    required super.totalRating,
    required super.totalReviews,
  });

  factory OnlineDoctorModel.fromJson(Map<String, dynamic> json) {
    return OnlineDoctorModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      fee: json['fee'] ?? 0,
      availability: json['availability'] ?? 0,
      qualification: json['qualification'] ?? '',
      specialization: json['specialization'] ?? '',
      totalRating: (json['total_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}