import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final int userId;
  final String otp;

  const LoginResponse({
    required this.userId,
    required this.otp,
  });

  @override
  List<Object> get props => [userId, otp];
}