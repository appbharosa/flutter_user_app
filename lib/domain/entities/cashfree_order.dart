class CashfreeOrder {
  final String paymentSessionId;
  final String orderId;
  final String amount;
  final String currency;
  final String? paymentLink;

  CashfreeOrder({
    required this.paymentSessionId,
    required this.orderId,
    required this.amount,
    required this.currency,
    this.paymentLink,
  });
}