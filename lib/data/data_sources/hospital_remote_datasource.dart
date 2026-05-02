import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/hospital_model.dart';

abstract class HospitalRemoteDataSource {
  Future<List<HospitalModel>> getHospitals({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });

  Future<int> getTotalPages();
}

class HospitalRemoteDataSourceImpl implements HospitalRemoteDataSource {
  final DioClient dioClient;
  int? _totalPages;

  HospitalRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<HospitalModel>> getHospitals({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        'lang': lang,
        'lat': lat.toString(),
        'lon': lon.toString(),
      };
      final response = await dioClient.dio.get(
        AppUrls.hospitalsList,
        queryParameters: queryParams,
      );
      if (response.data['status'] == 200) {
        final resultData = response.data['result'];
        // If result is not a List or empty, return empty list
        if (resultData is! List || resultData.isEmpty) {
          _totalPages = 1;
          return [];
        }
        final resultMap = resultData[0] as Map<String, dynamic>;
        final dataList = resultMap['data'] as List;
        _totalPages = resultMap['last_page'];
        return dataList.map((json) => HospitalModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load hospitals');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<int> getTotalPages() async {
    if (_totalPages == null) throw ServerException('No data loaded yet');
    return _totalPages!;
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