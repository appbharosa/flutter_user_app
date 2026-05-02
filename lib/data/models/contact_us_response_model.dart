import '../../domain/entities/contact_us_response.dart';

class ContactUsResponseModel extends ContactUsResponse {
  const ContactUsResponseModel({required super.success, required super.message});

  factory ContactUsResponseModel.fromJson(Map<String, dynamic> json) {
    // Your API returns 200 or 400 on success, and message "successfully submitted"
    final bool isSuccess = (json['status'] == 200 || json['status'] == 400) &&
        (json['message']?.toString().toLowerCase().contains('success') ?? false);
    return ContactUsResponseModel(
      success: isSuccess,
      message: json['message'] ?? 'Your query has been submitted',
    );
  }
}