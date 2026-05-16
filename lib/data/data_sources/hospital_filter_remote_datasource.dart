import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/hospital_filter_category_model.dart';

abstract class HospitalFilterRemoteDataSource {
  Future<List<HospitalFilterCategoryModel>> getFilters();
}

class HospitalFilterRemoteDataSourceImpl implements HospitalFilterRemoteDataSource {
  final DioClient dioClient;
  HospitalFilterRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<HospitalFilterCategoryModel>> getFilters() async {
    try {
      final response = await dioClient.dio.get(AppUrls.hospitalFilters);
      if (response.data['status'] == 200) {
        final List list = response.data['result'];
        return list.map((json) => HospitalFilterCategoryModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load filters');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) return NetworkException();
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final message = e.response?.data['message'] ?? 'Server error';
    return ServerException(message);
  }
}