
import 'package:equatable/equatable.dart';
import 'package:user/domain/entities/otp_response.dart';

abstract class OtpVerificationState extends Equatable {
  const OtpVerificationState();
  @override
  List<Object> get props => [];
}

class OtpVerificationInitial extends OtpVerificationState {}
class OtpVerificationLoading extends OtpVerificationState {}
class OtpVerificationSuccess extends OtpVerificationState {
  final OtpResponse userProfile;
  const OtpVerificationSuccess(this.userProfile);
  @override
  List<Object> get props => [userProfile];
}
class OtpVerificationError extends OtpVerificationState {
  final String message;
  const OtpVerificationError(this.message);
  @override
  List<Object> get props => [message];
}