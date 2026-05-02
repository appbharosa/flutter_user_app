import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(Map<String, dynamic> updatedData);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await dioClient.dio.get(AppUrls.profile);
      if (response.data['status'] == 200) {
        return UserProfileModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load profile');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final response = await dioClient.dio.put(AppUrls.updateProfile, data: updatedData);
      if (response.data['status'] == 200) {
        return UserProfileModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Update failed');
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
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final message = e.response?.data['message'] ?? 'Server error';
    return ServerException(message);
  }
}