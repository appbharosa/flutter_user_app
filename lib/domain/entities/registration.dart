
import 'package:equatable/equatable.dart';

class Registration extends Equatable {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final String gender;
  final String dob;
  final String? image;
  final String bloodGroup;
  final String coverageCategory;
  final String? nomineeFullName;
  final String? nomineeMobile;
  final String? nomineeDob;
  final String? nomineeRelationship;
  final String? nomineeGender;
  final String accessToken;  // added for token storage

  const Registration({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.gender,
    required this.dob,
    this.image,
    required this.bloodGroup,
    required this.coverageCategory,
    this.nomineeFullName,
    this.nomineeMobile,
    this.nomineeDob,
    this.nomineeRelationship,
    this.nomineeGender,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [id, name, email, accessToken];
}