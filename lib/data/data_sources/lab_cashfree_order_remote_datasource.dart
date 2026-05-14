import 'package:dio/dio.dart';

import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/cashfree_order.dart'; // reuse existing entity

abstract class LabCashfreeOrderRemoteDataSource {
  Future<CashfreeOrder> createOrder(double amount);
}

class LabCashfreeOrderRemoteDataSourceImpl implements LabCashfreeOrderRemoteDataSource {
  final DioClient dioClient;
  LabCashfreeOrderRemoteDataSourceImpl(this.dioClient);

  @override
  Future<CashfreeOrder> createOrder(double amount) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.labCreateCashfreeOrder,
        data: {'amount': amount, 'currency': 'INR'},
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        return CashfreeOrder(
          orderId: data['order_id'],
          paymentSessionId: data['payment_session_id'],
          amount: data['order_amount'].toString(),
          currency: data['order_currency'],
        );
      } else {
        throw ServerException(response.data['message'] ?? 'Order creation failed');
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