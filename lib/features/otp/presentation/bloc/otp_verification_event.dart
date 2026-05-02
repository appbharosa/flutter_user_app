import 'package:equatable/equatable.dart';

abstract class OtpVerificationEvent extends Equatable {
  const OtpVerificationEvent();
  @override
  List<Object> get props => [];
}

class VerifyOtpButtonPressed extends OtpVerificationEvent {
  final int userId;
  final String otp;
  const VerifyOtpButtonPressed({required this.userId, required this.otp});
  @override
  List<Object> get props => [userId, otp];
}