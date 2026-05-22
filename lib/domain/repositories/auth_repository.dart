
import 'package:dartz/dartz.dart';
import 'package:user/domain/entities/login_response.dart';
import 'package:user/domain/entities/otp_response.dart';
import 'package:user/domain/entities/registration.dart';

import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> sendOtp(String phoneNumber);
  Future<Either<Failure, OtpResponse>> verifyOtp(int userId, String otp);
  Future<Either<Failure, Registration>> registerUser(Map<String, dynamic> userData);
  Future<Either<Failure, OtpResponse>> getSavedUser();
  Future<Either<Failure, void>> logout();

}