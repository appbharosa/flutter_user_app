import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user/domain/entities/login_response.dart';
import 'package:user/domain/entities/otp_response.dart';
import 'package:user/domain/entities/registration.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/user_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';
import '../data_sources/user_local_datasource.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LoginResponse>> sendOtp(String phoneNumber) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure());
    }
    try {
      final otpModel = await remoteDataSource.sendOtp(phoneNumber);
      return Right(otpModel);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }


  @override
  Future<Either<Failure, OtpResponse>> verifyOtp(int userId, String otp) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure());
    }
    try {
      final userProfileModel = await remoteDataSource.verifyOtp(userId, otp);
      await localDataSource.saveUser(userProfileModel);

      // ✅ Save user data using UserManager
      await UserManager.saveUser(userProfileModel);

      return Right(userProfileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, OtpResponse>> getSavedUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        return Right(user);
      } else {
        return Left(NoUserFoundFailure());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Registration>> registerUser(Map<String, dynamic> userData) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final userModel = await remoteDataSource.registerUser(userData);
      const secureStorage = FlutterSecureStorage();

      if (userModel.accessToken.isNotEmpty) {
        await secureStorage.write(key: 'access_token', value: userModel.accessToken);
      }

      // ✅ Save user name and email using UserManager
      await UserManager.saveUserDetails(
        name: userModel.name,
        email: userModel.email,
      );

      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
  @override
  Future<Either<Failure, void>> logout() async {
    await localDataSource.clearUser();
    const secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'access_token');
    return const Right(null);
  }
}



