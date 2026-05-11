import 'package:equatable/equatable.dart';

class FamilyMember extends Equatable {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final String relationship;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.relationship,
  });

  @override
  List<Object?> get props => [id, name];
}