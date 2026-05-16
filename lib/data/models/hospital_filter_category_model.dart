import '../../domain/entities/hospital_filter_category.dart';
import 'hospital_filter_speciality_model.dart';

class HospitalFilterCategoryModel extends HospitalFilterCategory {
  const HospitalFilterCategoryModel({
    required super.id,
    required super.name,
    required super.specialities,
  });

  factory HospitalFilterCategoryModel.fromJson(Map<String, dynamic> json) {
    final specialitiesList = (json['specialities'] as List?) ?? [];
    final specialities = specialitiesList
        .map((s) => HospitalFilterSpecialityModel.fromJson(s))
        .toList();
    return HospitalFilterCategoryModel(
      id: json['category_id'],
      name: json['category_name'],
      specialities: specialities,
    );
  }
}