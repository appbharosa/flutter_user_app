import '../../domain/entities/online_doctor_speciality.dart';

class OnlineDoctorSpecialityModel extends OnlineDoctorSpeciality {
  const OnlineDoctorSpecialityModel({
    required super.id,
    required super.name,
    required super.image,
  });

  factory OnlineDoctorSpecialityModel.fromJson(Map<String, dynamic> json) {
    return OnlineDoctorSpecialityModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}