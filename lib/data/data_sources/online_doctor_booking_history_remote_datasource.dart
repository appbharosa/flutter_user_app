
import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/online_doctor_booking_item_model.dart';

abstract class OnlineDoctorBookingHistoryRemoteDataSource {
  Future<List<OnlineDoctorBookingItemModel>> getActiveBookings(String language);
  Future<List<OnlineDoctorBookingItemModel>> getCompletedBookings(String language);
}

class OnlineDoctorBookingHistoryRemoteDataSourceImpl implements OnlineDoctorBookingHistoryRemoteDataSource {
  final DioClient dioClient;
  OnlineDoctorBookingHistoryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<OnlineDoctorBookingItemModel>> getActiveBookings(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.onlineDoctorActive,
        queryParameters: {'lang': language},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<OnlineDoctorBookingItemModel>> getCompletedBookings(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.onlineDoctorCompleted,
        queryParameters: {'lang': language},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<OnlineDoctorBookingItemModel> _parseResponse(Response response) {
    if (response.data['status'] == 200) {
      final result = response.data['result'];
      List<dynamic> list = [];
      if (result is Map && result.containsKey('data')) {
        list = result['data'] ?? [];
      } else if (result is List) {
        list = result;
      }
      return list.map((json) => OnlineDoctorBookingItemModel.fromJson(json)).toList();
    } else {
      throw ServerException(response.data['message'] ?? 'Failed to load bookings');
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