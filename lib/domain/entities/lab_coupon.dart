
import 'package:equatable/equatable.dart';

class LabCoupon extends Equatable {
  final int id;
  final String name;
  final int percentage;
  final String description;

  const LabCoupon({
    required this.id,
    required this.name,
    required this.percentage,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name];
}