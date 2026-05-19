

import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/ambulance_booking_model.dart';

abstract class AmbulanceBookingRemoteDataSource {
  Future<AmbulanceBookingModel> bookAmbulance({
    required String language,
    required int mainDataId,
  });
}

class AmbulanceBookingRemoteDataSourceImpl implements AmbulanceBookingRemoteDataSource {
  final DioClient dioClient;
  AmbulanceBookingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AmbulanceBookingModel> bookAmbulance({
    required String language,
    required int mainDataId,
  }) async {
    try {
      final body = {
        'language': language,
        'main_data_id': mainDataId,
      };
      final response = await dioClient.dio.post(
        AppUrls.ambulanceBooking,
        data: body,
      );
      if (response.data['status'] == 200) {
        return AmbulanceBookingModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Booking failed');
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