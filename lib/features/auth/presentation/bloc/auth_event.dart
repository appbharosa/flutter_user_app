import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const SendOtpRequested(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}