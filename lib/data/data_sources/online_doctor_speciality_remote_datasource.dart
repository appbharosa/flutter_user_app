import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/online_doctor_speciality_model.dart';

abstract class OnlineDoctorSpecialityRemoteDataSource {
  Future<List<OnlineDoctorSpecialityModel>> getSpecialities(String lang);
}

class OnlineDoctorSpecialityRemoteDataSourceImpl implements OnlineDoctorSpecialityRemoteDataSource {
  final DioClient dioClient;
  OnlineDoctorSpecialityRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<OnlineDoctorSpecialityModel>> getSpecialities(String lang) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.onlineDoctorSpecialities,
        queryParameters: {'lang': lang},
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'] as Map<String, dynamic>;
        final dataList = result['data'] as List;
        return dataList.map((json) => OnlineDoctorSpecialityModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load specialities');
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