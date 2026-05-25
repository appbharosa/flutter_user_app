import 'package:equatable/equatable.dart';

class FamilyMembers extends Equatable {
  final int id;
  final String name;
  final String? type;
  final String relationship;

  const FamilyMembers({
    required this.id,
    required this.name,
    this.type,
    required this.relationship,
  });

  @override
  List<Object?> get props => [id, name, type, relationship];
}