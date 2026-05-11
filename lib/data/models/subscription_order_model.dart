import '../../domain/entities/subscription_order.dart';

class SubscriptionOrderModel extends SubscriptionOrder {
   SubscriptionOrderModel({
    required super.paymentSessionId,
    required super.orderId,
    required super.amount,
    required super.currency,
  });

  factory SubscriptionOrderModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SubscriptionOrderModel(
      paymentSessionId: data['payment_session_id'],
      orderId: data['order_id'],
      amount: data['order_amount'].toString(),
      currency: data['order_currency'],
    );
  }
}