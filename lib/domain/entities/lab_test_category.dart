
import 'package:equatable/equatable.dart';

class LabTestCategory extends Equatable {
  final int id;
  final String name;
  final String image;

  const LabTestCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  @override
  List<Object?> get props => [id, name];
}