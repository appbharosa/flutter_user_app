import '../../domain/entities/hospital_doctor.dart';

class HospitalDoctorModel extends HospitalDoctor {
  const HospitalDoctorModel({
    required super.id,
    required super.name,
    required super.specialization,
    required super.qualification,
    required super.experience,
    required super.consultationFee,
    required super.image,
    required super.rating,
    required super.reviewsCount,
  });

  factory HospitalDoctorModel.fromJson(Map<String, dynamic> json) {
    return HospitalDoctorModel(
      id: json['id'],
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? '',
      consultationFee: json['consultation_fee'] ?? 0,
      image: json['image'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
    );
  }
}