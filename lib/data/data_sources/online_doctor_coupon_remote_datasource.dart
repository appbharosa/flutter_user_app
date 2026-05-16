import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/online_doctor_coupon_model.dart';

abstract class OnlineDoctorCouponRemoteDataSource {
  Future<List<OnlineDoctorCouponModel>> getCoupons(String lang);
  Future<Map<String, dynamic>> applyCoupon(String couponCode, double amount);
}

class OnlineDoctorCouponRemoteDataSourceImpl implements OnlineDoctorCouponRemoteDataSource {
  final DioClient dioClient;
  OnlineDoctorCouponRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<OnlineDoctorCouponModel>> getCoupons(String lang) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.onlineDoctorCoupons,
        queryParameters: {'lang': lang},
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isEmpty) return [];
        final innerList = resultList[0] as List;
        return innerList.map((json) => OnlineDoctorCouponModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load coupons');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> applyCoupon(String couponCode, double amount) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.onlineDoctorApplyCoupon,
        data: {'coupon_code': couponCode, 'subtotal': amount},
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        return {
          'couponCode': result['code'],
          'discountAmount': (result['discount_amount'] as num).toDouble(),
          'finalAmount': (result['final_amount'] as num).toDouble(),
          'isValid': result['is_valid'],
        };
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to apply coupon');
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