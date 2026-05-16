import 'package:equatable/equatable.dart';

class OnlineDoctorCoupon extends Equatable {
  final int id;
  final String name;
  final int percentage;
  final String description;

  const OnlineDoctorCoupon({
    required this.id,
    required this.name,
    required this.percentage,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name];
}