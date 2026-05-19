import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/hospital_model.dart';

abstract class HospitalFilteredRemoteDataSource {
  Future<List<HospitalModel>> getFilteredHospitals({
    required String lang,
    required double lat,
    required double lon,
    required int catId,
    required String specialityIds,
  });
}

class HospitalFilteredRemoteDataSourceImpl implements HospitalFilteredRemoteDataSource {
  final DioClient dioClient;
  HospitalFilteredRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<HospitalModel>> getFilteredHospitals({
    required String lang,
    required double lat,
    required double lon,
    required int catId,
    required String specialityIds,
  }) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.filterHospitals,
        data: {
          'lang': lang,
          'lat': lat.toString(),
          'lon': lon.toString(),
          'cat_id': catId,
          'speciality_ids': specialityIds,
        },
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'] as Map<String, dynamic>;
        final dataList = result['data'] as List;
        return dataList.map((json) => HospitalModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load filtered hospitals');
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