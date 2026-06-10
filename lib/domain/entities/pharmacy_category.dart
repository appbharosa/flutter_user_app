import 'package:equatable/equatable.dart';

class PharmacyCategory extends Equatable {
  final int id;
  final String name;
  final String image;

  const PharmacyCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  @override
  List<Object?> get props => [id, name];
}