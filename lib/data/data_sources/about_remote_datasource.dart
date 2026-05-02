import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/about_model.dart';

abstract class AboutRemoteDataSource {
  Future<AboutModel> getAbout();
}

class AboutRemoteDataSourceImpl implements AboutRemoteDataSource {
  final DioClient dioClient;

  AboutRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AboutModel> getAbout() async {
    try {
      final response = await dioClient.dio.get(AppUrls.about);
      if (response.data['status'] == 200) {
        return AboutModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load about');
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