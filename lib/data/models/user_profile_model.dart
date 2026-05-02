import '../../core/utils/helpers.dart';
import '../../domain/entities/user_profile.dart';


class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.uniqueId,
    required super.name,
    required super.mobile,
    required super.email,
    required super.gender,
    required super.dob,
    required super.image,
    required super.bloodGroup,
    required super.coverageCategory,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      uniqueId: json['unique_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'].toString(),
      email: json['email'] ?? '',
      gender: Helpers.getGenderString(json['gender']), // converts 1→Male,2→Female
      dob: json['dob'] ?? '',
      image: json['image'] ?? '',
      bloodGroup: Helpers.getBloodGroupString(json['blood_group']),
      coverageCategory: Helpers.getCoverageString(json['coverage_category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unique_id': uniqueId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'gender': Helpers.getGenderCode(gender), // reverse mapping for update
      'dob': dob,
      'image': image,
      'blood_group': Helpers.getBloodGroupCode(bloodGroup),
      'coverage_category': Helpers.getCoverageCode(coverageCategory),
    };
  }
}