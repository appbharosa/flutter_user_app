import 'package:dartz/dartz.dart';
import 'package:user/domain/entities/otp_response.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';


class VerifyOtpParams {
  final int userId;
  final String otp;
  VerifyOtpParams({required this.userId, required this.otp});
}

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, OtpResponse>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.userId, params.otp);
  }
}