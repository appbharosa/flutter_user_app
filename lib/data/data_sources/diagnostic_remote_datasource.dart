import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/diagnostic_model.dart';

abstract class DiagnosticRemoteDataSource {
  Future<List<DiagnosticModel>> getDiagnostics({
    required int page,
    required int perPage,
    required String lang,
    required double lat,
    required double lon,
  });

  Future<int> getTotalPages();
}

class DiagnosticRemoteDataSourceImpl implements DiagnosticRemoteDataSource {
  final DioClient dioClient;
  int? _totalPages;

  DiagnosticRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<DiagnosticModel>> getDiagnostics({
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
      print("🩺 Diagnostics API call with params: $queryParams");
      final response = await dioClient.dio.get(
        AppUrls.diagnosticList,
        queryParameters: queryParams,
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) {
          _totalPages = 1;
          return [];
        }
        final resultMap = resultList[0] as Map<String, dynamic>;
        final dataList = resultMap['data'] as List;
        _totalPages = resultMap['last_page'];
        print("✅ Received ${dataList.length} diagnostics, total pages: $_totalPages");
        return dataList.map((json) => DiagnosticModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load diagnostics');
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