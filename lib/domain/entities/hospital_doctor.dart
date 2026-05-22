import 'package:equatable/equatable.dart';


class HospitalDoctor extends Equatable {
  final int id;
  final int mainDataId;
  final String name;
  final String specialization;
  final String qualification;        // comma-separated IDs (e.g. "41,2,1")
  final String qualificationNames;   // e.g. "DM Neurology, MBBS, MD"
  final int experience;              // years as integer
  final int consultationFee;
  final String image;
  final String phone;                // new field
  final int status;                  // 1 = active
  final String createdAt;
  final String? updatedAt;

  const HospitalDoctor({
    required this.id,
    required this.mainDataId,
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.qualificationNames,
    required this.experience,
    required this.consultationFee,
    required this.image,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HospitalDoctor.fromJson(Map<String, dynamic> json) {
    return HospitalDoctor(
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

  @override
  List<Object?> get props => [id, mainDataId, name];
}