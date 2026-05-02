

import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();
  @override List<Object> get props => [];
}

class SubmitRegistration extends RegistrationEvent {
  final Map<String, dynamic> userData;
  const SubmitRegistration(this.userData);
}