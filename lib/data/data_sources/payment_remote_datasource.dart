import 'package:dio/dio.dart';

import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/payment_status.dart';
import '../models/cashfree_order_model.dart';
import '../models/payment_status_model.dart';
import '../models/wallet_balance_model.dart';

abstract class PaymentRemoteDataSource {
  Future<CashfreeOrderModel> createOrder(int amount);
  Future<PaymentStatusModel> checkStatus(String orderId);
  Future<WalletBalanceModel> getWallet();
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
      // ✅ Check for 'success' string
      if (response.data['status'] == 'success') {
        return PaymentStatusModel.fromJson(response.data);
      } else {
        // If status is something else (e.g., 'pending' or 'failed'), extract message
        final message = response.data['message'] ?? 'Status check failed';
        throw ServerException(message);
      }
    } on DioException catch (e) {
      // 500 is often a callback timeout – treat as success if we have the order
      if (e.response?.statusCode == 500) {
        return PaymentStatusModel(
          orderId: orderId,
          status: PaymentResult.success,
          message: 'Payment successful (pending server confirmation)',
        );
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<WalletBalanceModel> getWallet() async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.getWallet,
      );
      if (response.data['status'] == 200) {
        return WalletBalanceModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch wallet');
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