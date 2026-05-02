import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/contact_us_response_model.dart';

abstract class ContactUsRemoteDataSource {
  Future<ContactUsResponseModel> submitContactUs({
    required int userId,
    required String name,
    required String email,
    required String mobile,
    required String message,
  });
}

class ContactUsRemoteDataSourceImpl implements ContactUsRemoteDataSource {
  final DioClient dioClient;

  ContactUsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ContactUsResponseModel> submitContactUs({
    required int userId,
    required String name,
    required String email,
    required String mobile,
    required String message,
  }) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.contactUs,
        data: {
          'user_id': userId,
          'name': name,
          'email': email,
          'mobile': mobile,
          'message': message,
        },
      );
      if (response.data['status'] == 200 || response.data['status'] == 400) {
        return ContactUsResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Submission failed');
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