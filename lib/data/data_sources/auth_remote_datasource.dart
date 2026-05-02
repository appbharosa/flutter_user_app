import 'package:dio/dio.dart';
import 'package:user/data/models/login_response_model.dart';
import 'package:user/data/models/otp_response_model.dart';
import 'package:user/data/models/user_register_model.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';


abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> sendOtp(String phoneNumber);
  Future<OtpResponseModel> verifyOtp(int userId, String otp);
  Future<UserRegisterModel> registerUser(Map<String, dynamic> userData);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LoginResponseModel> sendOtp(String phoneNumber) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.login,
        data: {"phone": phoneNumber},
      );
      if (response.data['status'] == 200) {
        final resultJson = response.data['result'];
        return LoginResponseModel.fromJson(resultJson);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<OtpResponseModel> verifyOtp(int userId, String otp) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.otpVerification,
        data: {"user_id": userId, "otp": otp},
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isNotEmpty) {
          return OtpResponseModel.fromJson(resultList.first);
        } else {
          throw ServerException('User not found');
        }
      } else {
        throw ServerException(response.data['message'] ?? 'Verification failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserRegisterModel> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await dioClient.dio.post(AppUrls.registration, data: userData);
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isNotEmpty) {
          return UserRegisterModel.fromJson(resultList.first);
        } else {
          throw ServerException('No user data returned');
        }
      } else {
        throw ServerException(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) {
      return UnauthorizedException();
    }
    final message = e.response?.data['message'] ?? 'Something went wrong';
    return ServerException(message);
  }
}
