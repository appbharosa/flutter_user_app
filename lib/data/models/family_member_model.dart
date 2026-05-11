import '../../domain/entities/family_member.dart';

class FamilyMemberModel extends FamilyMember {
  const FamilyMemberModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    required super.relationship,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return FamilyMemberModel(
      id: parseId(json['id']),
      name: json['name'] ?? '',
      mobile: json['mobile'].toString(),
      email: json['email'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }
}