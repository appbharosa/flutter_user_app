import '../../domain/entities/payment_status.dart';

import '../../domain/entities/payment_status.dart';

class PaymentStatusModel extends PaymentStatus {
   PaymentStatusModel({
    required super.orderId,
    required super.status,
    super.message,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    // The actual response wraps data inside "response"
    final responseData = json['response'] ?? json;
    final orderStatus = responseData['order_status'] ?? 'PENDING';
    PaymentResult result;
    switch (orderStatus.toUpperCase()) {
      case 'PAID':
      case 'SUCCESS':
        result = PaymentResult.success;
        break;
      case 'FAILED':
        result = PaymentResult.failed;
        break;
      default:
        result = PaymentResult.pending;
    }
    return PaymentStatusModel(
      orderId: responseData['order_id']?.toString() ?? '',
      status: result,
      message: json['message'],
    );
  }
}