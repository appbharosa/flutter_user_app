
import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/hospital_pharmacy_booking_item_model.dart';

abstract class HospitalPharmacyBookingHistoryRemoteDataSource {
  Future<List<HospitalPharmacyBookingItemModel>> getOngoingBookings(String language);
  Future<List<HospitalPharmacyBookingItemModel>> getCompletedBookings(String language);
}

class HospitalPharmacyBookingHistoryRemoteDataSourceImpl
    implements HospitalPharmacyBookingHistoryRemoteDataSource {
  final DioClient dioClient;
  HospitalPharmacyBookingHistoryRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<HospitalPharmacyBookingItemModel>> getOngoingBookings(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.hospitalPharmacyOngoing,
        queryParameters: {'lang': language},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<HospitalPharmacyBookingItemModel>> getCompletedBookings(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.hospitalPharmacyCompleted,
        queryParameters: {'lang': language},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<HospitalPharmacyBookingItemModel> _parseResponse(Response response) {
    if (response.data['status'] == 200) {
      final result = response.data['result'];
      List<dynamic> list = [];

      if (result is List && result.isNotEmpty) {
        // Ongoing endpoint returns a list with a pagination object containing 'data'
        final pagination = result[0];
        if (pagination is Map && pagination.containsKey('data')) {
          list = pagination['data'] ?? [];
        }
      } else if (result is List && result.isEmpty) {
        // Completed endpoint might return empty list
        list = [];
      } else if (result is Map && result.containsKey('data')) {
        // Alternative structure: direct result with 'data'
        list = result['data'] ?? [];
      }

      return list.map((json) => HospitalPharmacyBookingItemModel.fromJson(json)).toList();
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