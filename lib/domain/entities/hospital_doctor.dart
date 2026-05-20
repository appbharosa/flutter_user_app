import 'package:equatable/equatable.dart';

class HospitalDoctor extends Equatable {
  final int id;
  final int mainDataId; // new
  final String name;
  final String specialization;
  final String qualification;
  final String experience;
  final int consultationFee;
  final String image;
  final double rating;
  final int reviewsCount;

  const HospitalDoctor({
    required this.id,
    required this.mainDataId,
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.experience,
    required this.consultationFee,
    required this.image,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  List<Object?> get props => [id, mainDataId, name];
}