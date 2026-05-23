class AddFamilyMemberRequest {
  final int userId;
  final String name;
  final String email;
  final String mobile;
  final String gender;
  final String dob;
  final int bloodGroup;
  final int coverageCategory;
  final String relationship;

  AddFamilyMemberRequest({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.coverageCategory,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'mobile': mobile,
    'gender': gender,
    'dob': dob,
    'blood_group': bloodGroup,
    'coverage_category': coverageCategory.toString(),
    'relationship': relationship,
  };
}