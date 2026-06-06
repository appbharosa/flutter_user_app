// lib/data/datasources/lab_test_category_remote_datasource_impl.dart
import 'package:dio/dio.dart';

import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../data_sources/lab_test_category_remote_datasource.dart';
import '../models/lab_test_category_response_model.dart';

class LabTestCategoryRemoteDataSourceImpl implements LabTestCategoryRemoteDataSource {
  final DioClient dioClient;

  LabTestCategoryRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LabTestCategoryResponseModel> getCategories({
    required int page,
    required int perPage,
    required String language,
  }) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.freeLabCategory,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'lang': language,
        },
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'] as List;
        if (result.isEmpty) {
          throw ServerException('No data found');
        }
        final paginationMap = result[0] as Map<String, dynamic>;
        return LabTestCategoryResponseModel.fromJson(paginationMap);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load categories');
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