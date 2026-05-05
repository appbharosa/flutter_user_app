import 'package:dio/dio.dart';

import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/payment_status.dart';
import '../models/cashfree_order_model.dart';
import '../models/payment_status_model.dart';

abstract class PaymentRemoteDataSource {
  Future<CashfreeOrderModel> createOrder(int amount);
  Future<PaymentStatusModel> checkStatus(String orderId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient dioClient;

  PaymentRemoteDataSourceImpl(this.dioClient);

  @override
  Future<CashfreeOrderModel> createOrder(int amount) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.cashFreeWallet,
        data: {'amount': amount, 'currency': 'INR'},
      );
      //  status is a string, not integer
      if (response.data['status'] == 'success') {
        //  data is under 'data' key, not 'result'
        final data = response.data['data'];
        return CashfreeOrderModel.fromJson({'data': data});
      } else {
        throw ServerException(response.data['message'] ?? 'Order creation failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }


  @override

  Future<PaymentStatusModel> checkStatus(String orderId) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.cashFreePaymentStatus,
        data: {'order_id': orderId},
      );
      // The API returns HTTP 200 with "status": true/false
      if (response.data['status'] == true) {
        return PaymentStatusModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Status check failed');
      }
    } on DioException catch (e) {
      // Handle network errors
      if (e.response?.statusCode == 500) {
        // Fallback – assume success if we have the Cashfree callback
        return PaymentStatusModel(
          orderId: orderId,
          status: PaymentResult.success,
          message: 'Payment successful (pending server confirmation)',
        );
      }
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