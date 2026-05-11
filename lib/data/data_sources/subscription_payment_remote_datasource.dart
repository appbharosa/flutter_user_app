import 'package:dio/dio.dart';
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
      final response = await dioClient.dio.post(
        AppUrls.createOrder,
        data: {'amount': amount, 'currency': 'INR'},
      );
      if (response.data['status'] == 'success') {
        return SubscriptionOrderModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Order creation failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> submitSubscription(String orderId, int subscriptionId) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.checkSubscriptionStatus,
        data: {'order_id': orderId, 'subscription_id': subscriptionId},
      );
      if (response.data['status'] != 'success') {
        throw ServerException(response.data['message'] ?? 'Subscription activation failed');
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