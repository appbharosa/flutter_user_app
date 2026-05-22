
class AddFamilyMemberResponse {
  final bool success;
  final String message;
  final int? familyMemberId;

  AddFamilyMemberResponse({required this.success, required this.message, this.familyMemberId});

  factory AddFamilyMemberResponse.fromJson(Map<String, dynamic> json) {
    return AddFamilyMemberResponse(
      success: json['status'] == 200,
      message: json['message'] ?? '',
      familyMemberId: json['result']['id'],
    );
  }
}