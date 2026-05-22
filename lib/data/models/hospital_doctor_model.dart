import '../../domain/entities/hospital_doctor.dart';

class HospitalDoctorModel extends HospitalDoctor {
  const HospitalDoctorModel({
    required super.id,
    required super.mainDataId,
    required super.name,
    required super.specialization,
    required super.qualification,
    required super.qualificationNames,
    required super.experience,
    required super.consultationFee,
    required super.image,
    required super.phone,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory HospitalDoctorModel.fromJson(Map<String, dynamic> json) {
    return HospitalDoctorModel(
      id: json['id'] ?? 0,
      mainDataId: json['main_data_id'] ?? 0,
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      qualification: json['qualification'] ?? '',
      qualificationNames: json['qualification_names'] ?? '',
      experience: json['experience'] ?? 0,
      consultationFee: json['consultation_fee'] ?? 0,
      image: json['image'] ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status'] ?? 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }
}