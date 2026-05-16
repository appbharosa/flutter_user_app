import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/online_doctor_slots_response_model.dart';

abstract class OnlineDoctorSlotRemoteDataSource {
  Future<OnlineDoctorSlotsResponseModel> getSlots(String date);
}

class OnlineDoctorSlotRemoteDataSourceImpl implements OnlineDoctorSlotRemoteDataSource {
  final DioClient dioClient;
  OnlineDoctorSlotRemoteDataSourceImpl(this.dioClient);

  @override
  Future<OnlineDoctorSlotsResponseModel> getSlots(String date) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.onlineDoctorSlots,
        queryParameters: {'date': date},
      );
      if (response.data['status'] == 200) {
        return OnlineDoctorSlotsResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load slots');
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