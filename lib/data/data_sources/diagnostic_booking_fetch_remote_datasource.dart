import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/diagnostic_booking_fetch_item_model.dart';
import '../models/diagnostic_booking_fetch_detail_model.dart';



abstract class DiagnosticBookingFetchRemoteDataSource {
  Future<List<DiagnosticBookingFetchItemModel>> getOngoingBookings(int page, int perPage);
  Future<List<DiagnosticBookingFetchItemModel>> getCompletedBookings(int page, int perPage);
  Future<DiagnosticBookingFetchDetailModel> getBookingDetail(String bookingId);
}

class DiagnosticBookingFetchRemoteDataSourceImpl implements DiagnosticBookingFetchRemoteDataSource {
  final DioClient dioClient;
  DiagnosticBookingFetchRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<DiagnosticBookingFetchItemModel>> getOngoingBookings(int page, int perPage) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.ongoingDiagnosticBookings,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) return [];
        final dataList = resultList[0]['data'] as List;
        return dataList.map((json) => DiagnosticBookingFetchItemModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load ongoing bookings');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<DiagnosticBookingFetchItemModel>> getCompletedBookings(int page, int perPage) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.completedDiagnosticBookings,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) return [];
        final dataList = resultList[0]['data'] as List;
        return dataList.map((json) => DiagnosticBookingFetchItemModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load completed bookings');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DiagnosticBookingFetchDetailModel> getBookingDetail(String bookingId) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.eachDiagnosticBooking,
        queryParameters: {'booking_id': bookingId},
      );
      if (response.data['status'] == 200) {
        return DiagnosticBookingFetchDetailModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load booking details');
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