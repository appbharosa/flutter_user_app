import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Unauthorized');
}
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
class NoUserFoundFailure extends Failure {
  const NoUserFoundFailure() : super('No logged in user found');
}
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure(String message) : super(message);
}