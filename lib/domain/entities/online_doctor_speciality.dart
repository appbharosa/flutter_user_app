import 'package:equatable/equatable.dart';

class OnlineDoctorSpeciality extends Equatable {
  final int id;
  final String name;
  final String image;

  const OnlineDoctorSpeciality({
    required this.id,
    required this.name,
    required this.image,
  });

  @override
  List<Object?> get props => [id, name];
}