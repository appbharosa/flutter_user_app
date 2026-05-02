import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class OtpInitial extends AuthState {}

class OtpLoading extends AuthState {}

class OtpSent extends AuthState {
  final int userId;
  final String otp; // In real app, don't show OTP in UI; this is for testing
  const OtpSent({required this.userId, required this.otp});
  @override
  List<Object> get props => [userId, otp];
}

class OtpError extends AuthState {
  final String message;
  const OtpError(this.message);
  @override
  List<Object> get props => [message];
}