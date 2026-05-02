import 'failures.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message = 'No internet connection';
}

class UnauthorizedException implements Exception {
  final String message = 'Session expired';
}
class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);
}

class CacheException implements Exception {}