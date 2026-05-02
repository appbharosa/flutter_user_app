
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/registration.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();
  @override List<Object> get props => [];
}

class RegistrationInitial extends RegistrationState {}
class RegistrationLoading extends RegistrationState {}
class RegistrationSuccess extends RegistrationState {
  final Registration registration;
  const RegistrationSuccess(this.registration);
}
class RegistrationError extends RegistrationState {
  final String message;
  const RegistrationError(this.message);
}