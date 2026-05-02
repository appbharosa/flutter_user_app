
import 'package:equatable/equatable.dart';

abstract class ContactUsState extends Equatable {
  const ContactUsState();
  @override
  List<Object> get props => [];
}

class ContactUsInitial extends ContactUsState {}
class ContactUsLoading extends ContactUsState {}
class ContactUsSuccess extends ContactUsState {
  final String message;
  const ContactUsSuccess(this.message);
  @override
  List<Object> get props => [message];
}
class ContactUsError extends ContactUsState {
  final String message;
  const ContactUsError(this.message);
  @override
  List<Object> get props => [message];
}