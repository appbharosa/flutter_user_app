class SubscriptionOrder {
  final String paymentSessionId;
  final String orderId;
  final String amount;
  final String currency;

  SubscriptionOrder({
    required this.paymentSessionId,
    required this.orderId,
    required this.amount,
    required this.currency,
  });
}