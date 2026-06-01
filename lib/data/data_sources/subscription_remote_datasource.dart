import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user_subscription.dart';
import '../models/subscription_plan_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<UserSubscription?> getUserSubscription(String language);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final DioClient dioClient;

  SubscriptionRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final response = await dioClient.dio.get(AppUrls.subscriptionList);

      print("📦 Subscription plans response status: ${response.data['status']}");
      print("📦 Subscription plans response message: ${response.data['message']}");

      if (response.data['status'] == 200) {
        final List list = response.data['result'];
        return list.map((json) => SubscriptionPlanModel.fromJson(json)).toList();
      } else {
        print("❌ Throwing ServerException with message: ${response.data['message']}");
        throw ServerException(response.data['message'] ?? 'Failed to load plans');
      }
    } on DioException catch (e) {
      print("❌ DioException: ${e.message}");
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserSubscription?> getUserSubscription(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.subscriptionStatus,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        if (result is List && result.isNotEmpty) {
          return UserSubscription.fromJson(result[0]);
        }
        return null;
      } else {
        return null;
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