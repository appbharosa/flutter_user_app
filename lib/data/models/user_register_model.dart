// lib/data/models/user_profile_model.dart
import 'package:user/domain/entities/registration.dart';

import 'dart:convert';
import '../../domain/entities/registration.dart';

class UserRegisterModel extends Registration {
  const UserRegisterModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    required super.gender,
    required super.dob,
    super.image,
    required super.bloodGroup,
    required super.coverageCategory,
    super.nomineeFullName,
    super.nomineeMobile,
    super.nomineeDob,
    super.nomineeRelationship,
    super.nomineeGender,
    required super.accessToken,
  });

  factory UserRegisterModel.fromJson(Map<String, dynamic> json) {
    return UserRegisterModel(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'].toString(),
      email: json['email'],
      gender: json['gender'],
      dob: json['dob'],
      image: json['image'],
      bloodGroup: json['blood_group'].toString(),
      coverageCategory: json['coverage_category'].toString(),
      accessToken: json['auth_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'gender': gender,
      'dob': dob,
      'image': image,
      'blood_group': bloodGroup,
      'coverage_category': coverageCategory,
      'nominee_full_name': nomineeFullName,
      'nominee_mobile': nomineeMobile,
      'nominee_date_of_birth': nomineeDob,
      'nominee_relationship': nomineeRelationship,
      'nominee_gender': nomineeGender,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}