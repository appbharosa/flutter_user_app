import '../../domain/entities/hospital_filter_speciality.dart';


class HospitalFilterSpecialityModel extends HospitalFilterSpeciality {
  const HospitalFilterSpecialityModel({
    required super.id,
    required super.name,
  });

  factory HospitalFilterSpecialityModel.fromJson(Map<String, dynamic> json) {
    return HospitalFilterSpecialityModel(
      id: json['speciality_id'],
      name: json['speciality_name'],
    );
  }
}