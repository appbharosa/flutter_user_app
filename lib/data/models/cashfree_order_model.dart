import '../../domain/entities/cashfree_order.dart';

class CashfreeOrderModel extends CashfreeOrder {
   CashfreeOrderModel({
    required super.paymentSessionId,
    required super.orderId,
    required super.amount,
    required super.currency,
    super.paymentLink,
  });

  factory CashfreeOrderModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CashfreeOrderModel(
      paymentSessionId: data['payment_session_id'],
      orderId: data['order_id'],
      amount: data['order_amount'].toString(),
      currency: data['order_currency'],
      paymentLink: data['payment_link'],
    );
  }
}