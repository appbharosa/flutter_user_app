

import 'package:equatable/equatable.dart';

abstract class ContactUsEvent extends Equatable {
  const ContactUsEvent();
  @override
  List<Object> get props => [];
}

class SubmitContactUs extends ContactUsEvent {
  final int userId;
  final String name;
  final String email;
  final String mobile;
  final String message;

  const SubmitContactUs({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.message,
  });

  @override
  List<Object> get props => [userId, name, email, mobile, message];
}