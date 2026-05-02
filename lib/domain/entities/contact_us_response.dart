import 'package:equatable/equatable.dart';

class ContactUsResponse extends Equatable {
  final bool success;
  final String message;

  const ContactUsResponse({required this.success, required this.message});

  @override
  List<Object> get props => [success, message];
}