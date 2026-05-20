
import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/doctor_slot_model.dart';

abstract class DoctorSlotsRemoteDataSource {
  Future<DoctorSlotsResponseModel> getDoctorSlots({
    required int doctorId,
    required String language,
    String? date,
  });
}

class DoctorSlotsRemoteDataSourceImpl implements DoctorSlotsRemoteDataSource {
  final DioClient dioClient;
  DoctorSlotsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DoctorSlotsResponseModel> getDoctorSlots({
    required int doctorId,
    required String language,
    String? date,
  }) async {
    final queryParams = {
      'doctor_id': doctorId,
      'lang': language,
    };
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date; // include date if provided
    }
    final response = await dioClient.dio.get(
      AppUrls.hospitalDoctorSlots,
      queryParameters: queryParams,
    );
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date; // include date if provided
      }
      if (response.data['status'] == 200) {
        return DoctorSlotsResponseModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load slots');
      }
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
