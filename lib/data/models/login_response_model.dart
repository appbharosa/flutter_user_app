import 'package:user/domain/entities/login_response.dart';

class LoginResponseModel extends LoginResponse {
  const LoginResponseModel({
    required super.userId,
    required super.otp,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      userId: json['user_id'],
      otp: json['otp'].toString(), // Convert to string if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'otp': otp,
    };
  }
}