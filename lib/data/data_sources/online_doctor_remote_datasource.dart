import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/online_doctor_model.dart';

abstract class OnlineDoctorRemoteDataSource {
  Future<List<OnlineDoctorModel>> getDoctors({
    required int page,
    required int perPage,
    required String lang,
    int? specialityId,
  });
  Future<int> getTotalPages();
  void clearTotalPagesCache(); // 👈 new method to reset cache
}

class OnlineDoctorRemoteDataSourceImpl implements OnlineDoctorRemoteDataSource {
  final DioClient dioClient;
  int? _cachedTotalPages;

  OnlineDoctorRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<OnlineDoctorModel>> getDoctors({
    required int page,
    required int perPage,
    required String lang,
    int? specialityId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        'lang': lang,
      };
      if (specialityId != null && specialityId > 0) {
        queryParams['speciality_id'] = specialityId;
      }
      final response = await dioClient.dio.get(
        AppUrls.onlineDoctorsList,
        queryParameters: queryParams,
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) {
          // No data – ensure cache is set to 1 if still null
          _cachedTotalPages ??= 1;
          return [];
        }
        final paginationMap = resultList[0] as Map<String, dynamic>;
        final dataList = paginationMap['data'] as List;
        // Only cache total pages on the first request (page == 1)
        if (page == 1) {
          _cachedTotalPages = paginationMap['last_page'] as int;
        }
        return dataList.map((json) => OnlineDoctorModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load online doctors');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<int> getTotalPages() async {
    if (_cachedTotalPages == null) {
      throw ServerException('No data loaded yet. Call getDoctors first.');
    }
    return _cachedTotalPages!;
  }

  @override
  void clearTotalPagesCache() {
    _cachedTotalPages = null;
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

