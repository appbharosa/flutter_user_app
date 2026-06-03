import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';

abstract class FreeLabReportRemoteDataSource {
  Future<List<Map<String, dynamic>>> getFreeLabReports(String language);
}

class FreeLabReportRemoteDataSourceImpl implements FreeLabReportRemoteDataSource {
  final DioClient dioClient;

  FreeLabReportRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<Map<String, dynamic>>> getFreeLabReports(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.getFreeLabReports,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'] as List;
        if (result.isNotEmpty && result[0]['lab_reports'] is List) {
          return List<Map<String, dynamic>>.from(result[0]['lab_reports']);
        }
        return [];
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load reports');
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