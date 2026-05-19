import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/hospital_main_data_model.dart';
import '../models/hospital_doctor_model.dart';

abstract class HospitalMainDataRemoteDataSource {
  Future<(HospitalMainDataModel, List<HospitalDoctorModel>)> getHospitalData(int mainDataId);
}

class HospitalMainDataRemoteDataSourceImpl implements HospitalMainDataRemoteDataSource {
  final DioClient dioClient;
  HospitalMainDataRemoteDataSourceImpl(this.dioClient);

  @override
  Future<(HospitalMainDataModel, List<HospitalDoctorModel>)> getHospitalData(int mainDataId) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.hospitalMainData,
        queryParameters: {'main_data_id': mainDataId},
      );
      if (response.data['status'] == 200) {
        final data = response.data['data'];
        final mainDataJson = data['main_data'];
        final doctorsList = data['doctors'] as List;
        final hospital = HospitalMainDataModel.fromJson(mainDataJson);
        final doctors = doctorsList.map((d) => HospitalDoctorModel.fromJson(d)).toList();
        return (hospital, doctors);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load hospital data');
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