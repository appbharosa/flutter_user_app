import 'package:equatable/equatable.dart';

import 'hospital_filter_speciality.dart';


class HospitalFilterCategory extends Equatable {
  final int id;
  final String name;
  final List<HospitalFilterSpeciality> specialities;

  const HospitalFilterCategory({
    required this.id,
    required this.name,
    required this.specialities,
  });

  @override
  List<Object?> get props => [id, name, specialities];
}