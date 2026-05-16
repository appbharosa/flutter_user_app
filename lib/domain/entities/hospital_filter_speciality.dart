import 'package:equatable/equatable.dart';

class HospitalFilterSpeciality extends Equatable {
  final int id;
  final String name;

  const HospitalFilterSpeciality({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}