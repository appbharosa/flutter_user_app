
import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard(String language);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;
  DashboardRemoteDataSourceImpl(this.dioClient);

  @override
  Future<DashboardModel> getDashboard(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.dashboard,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        return DashboardModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load dashboard');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
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