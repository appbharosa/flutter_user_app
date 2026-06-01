import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/subscription_order_model.dart';

abstract class SubscriptionPaymentRemoteDataSource {
  Future<SubscriptionOrderModel> createOrder(int amount);
  Future<void> submitSubscription(String orderId, int subscriptionId);
}

class SubscriptionPaymentRemoteDataSourceImpl implements SubscriptionPaymentRemoteDataSource {
  final DioClient dioClient;

  SubscriptionPaymentRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SubscriptionOrderModel> createOrder(int amount) async {
    try {
      debugPrint("🔵 Creating order with amount: $amount");

      final response = await dioClient.dio.post(
        AppUrls.createOrder,
        data: {'amount': amount, 'currency': 'INR'},
      );

      debugPrint("📦 Create order response: ${response.data}");

      // Handle both 'success' string and 200 status code
      final status = response.data['status'];
      if (status == 200 || status == 'success') {
        return SubscriptionOrderModel.fromJson(response.data);
      } else {
        final errorMsg = response.data['message'] ?? 'Order creation failed';
        debugPrint("❌ Create order failed: $errorMsg");
        throw ServerException(errorMsg);
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException in createOrder: ${e.message}");
      throw _handleDioError(e);
    }
  }
  @override
  Future<void> submitSubscription(String orderId, int subscriptionId) async {
    try {
      debugPrint("🔵 Submitting subscription - orderId: $orderId, subscriptionId: $subscriptionId");

      final requestData = {
        'order_id': orderId,
        'subscription_id': subscriptionId,
      };

      debugPrint("📤 Submitting subscription with data: $requestData");

      final response = await dioClient.dio.post(
        AppUrls.checkSubscriptionStatus,
        data: requestData,
      );

      debugPrint("📦 Submit subscription response: ${response.data}");

      // ✅ Fix: Check for 'success' string or 200 status
      final status = response.data['status'];
      if (status == 'success' || status == 200) {
        debugPrint("✅ Subscription submitted successfully");
        return;
      } else {
        final errorMsg = response.data['message'] ?? 'Subscription activation failed';
        debugPrint("❌ Submit subscription failed: $errorMsg");
        throw ServerException(errorMsg);
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException in submitSubscription: ${e.message}");
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
    final message = e.response?.data?['message'] ?? 'Server error';
    return ServerException(message);
  }
}