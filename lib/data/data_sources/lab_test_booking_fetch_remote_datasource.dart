import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/lab_test_booking_fetch_item_model.dart';
import '../models/lab_test_booking_fetch_detail_model.dart';


abstract class LabTestBookingFetchRemoteDataSource {
  Future<List<LabTestBookingFetchItemModel>> getOngoingBookings(int page, int perPage);
  Future<List<LabTestBookingFetchItemModel>> getCompletedBookings(int page, int perPage);
  Future<LabTestBookingFetchDetailModel> getBookingDetail(String bookingId);
}

class LabTestBookingFetchRemoteDataSourceImpl implements LabTestBookingFetchRemoteDataSource {
  final DioClient dioClient;
  LabTestBookingFetchRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<LabTestBookingFetchItemModel>> getOngoingBookings(int page, int perPage) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.labOngoingBookings,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) return [];
        final dataList = resultList[0]['data'] as List;
        return dataList.map((json) => LabTestBookingFetchItemModel.fromJson(json, isCompleted: false)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load ongoing lab bookings');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<LabTestBookingFetchItemModel>> getCompletedBookings(int page, int perPage) async {
    try {
      print(" Calling completed API: ${AppUrls.labCompletedBookings}?page=$page&per_page=$perPage");
      final response = await dioClient.dio.get(
        AppUrls.labCompletedBookings,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      print(" Completed API response status: ${response.statusCode}, body: ${response.data}");
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) return [];
        final dataList = resultList[0]['data'] as List;
        return dataList.map((json) => LabTestBookingFetchItemModel.fromJson(json, isCompleted: true)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load completed lab bookings');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<LabTestBookingFetchDetailModel> getBookingDetail(String bookingId) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.labBookingDetails,
        queryParameters: {'booking_id': bookingId},
      );
      if (response.data['status'] == 200) {
        return LabTestBookingFetchDetailModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load lab booking details');
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