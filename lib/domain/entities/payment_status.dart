enum PaymentResult { success, failed, pending }

class PaymentStatus {
  final String orderId;
  final PaymentResult status;
  final String? message;

  PaymentStatus({required this.orderId, required this.status, this.message});
}