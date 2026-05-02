import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String uniqueId;
  final String name;
  final String mobile;
  final String email;
  final String gender;    // store as string from mapping
  final String dob;
  final String image;
  final String bloodGroup;
  final String coverageCategory;

  const UserProfile({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.gender,
    required this.dob,
    required this.image,
    required this.bloodGroup,
    required this.coverageCategory,
  });

  @override
  List<Object> get props => [id, name, email];
}