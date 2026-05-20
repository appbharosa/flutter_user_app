
import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/doctor_coupon_model.dart';
import '../models/applied_coupon_model.dart';

abstract class DoctorCouponRemoteDataSource {
  Future<List<DoctorCouponModel>> getCoupons(String language);
  Future<AppliedCouponModel> applyCoupon({
    required String couponCode,
    required int subtotal,
    required String language,
  });
}

class DoctorCouponRemoteDataSourceImpl implements DoctorCouponRemoteDataSource {
  final DioClient dioClient;
  DoctorCouponRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DoctorCouponModel>> getCoupons(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.hospitalDoctorCoupon,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        List<dynamic> list = [];
        if (result is List && result.isNotEmpty) {
          list = result[0] as List? ?? [];
        }
        return list.map((json) => DoctorCouponModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load coupons');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AppliedCouponModel> applyCoupon({
    required String couponCode,
    required int subtotal,
    required String language,
  }) async {
    try {
      final body = {
        'coupon_code': couponCode,
        'subtotal': subtotal,
        'lang': language,
      };
      final response = await dioClient.dio.post(
        AppUrls.hospitalDoctorApplyCoupon,
        data: body,
      );
      if (response.data['status'] == 200) {
        return AppliedCouponModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to apply coupon');
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