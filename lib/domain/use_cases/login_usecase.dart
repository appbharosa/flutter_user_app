import 'package:dartz/dartz.dart';
import 'package:user/domain/entities/login_response.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';


class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, LoginResponse>> call(String phoneNumber) {
    // Optional: Add validation here (e.g., phone number length)
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      return Future.value(Left(ValidationFailure('Invalid phone number')));
    }
    return repository.sendOtp(phoneNumber);
  }
}