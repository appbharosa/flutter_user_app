import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/hospital_diagnostic_booking_item_model.dart';

abstract class HospitalBookingHistoryRemoteDataSource {
  Future<List<HospitalDiagnosticBookingItemModel>> getOngoingBookings(String language);
  Future<List<HospitalDiagnosticBookingItemModel>> getCompletedBookings(String language);
}

class HospitalBookingHistoryRemoteDataSourceImpl implements HospitalBookingHistoryRemoteDataSource {
  final DioClient dioClient;
  HospitalBookingHistoryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<HospitalDiagnosticBookingItemModel>> getOngoingBookings(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.hospitalDiagnosticOngoing,
        queryParameters: {'lang': language},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<HospitalDiagnosticBookingItemModel>> getCompletedBookings(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.hospitalDiagnosticCompleted,
        queryParameters: {'lang': language},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<HospitalDiagnosticBookingItemModel> _parseResponse(Response response) {
    if (response.data['status'] == 200) {
      final result = response.data['result'];
      List<dynamic> list = [];
      if (result is List) {
        list = result;
      } else if (result is Map && result.containsKey('history')) {
        list = result['history'] ?? [];
      }
      return list.map((json) => HospitalDiagnosticBookingItemModel.fromJson(json)).toList();
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