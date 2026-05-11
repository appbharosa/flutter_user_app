import 'package:user/data/models/pharmacy_order_status.dart';

enum OrderStatus {
  none,       // No order
  waiting,    // Waiting for acceptance
  accepted,   // Order accepted
  billingReceived, // Billing received
}

class PharmacyOrder {
  final String orderId;
  final OrderStatus status;
  final String? billingImageUrl;
  final DateTime? acceptedAt;
  final DateTime? billingReceivedAt;

  PharmacyOrder({
    required this.orderId,
    required this.status,
    this.billingImageUrl,
    this.acceptedAt,
    this.billingReceivedAt,
  });

  // Static instances for demo
  static PharmacyOrder none = PharmacyOrder(
    orderId: "",
    status: OrderStatus.none,
  );

  static PharmacyOrder waiting = PharmacyOrder(
    orderId: "ORD12345",
    status: OrderStatus.waiting,
  );

  static PharmacyOrder accepted = PharmacyOrder(
    orderId: "ORD12345",
    status: OrderStatus.accepted,
    acceptedAt: DateTime.now(),
  );

  static PharmacyOrder billingReceived = PharmacyOrder(
    orderId: "ORD12345",
    status: OrderStatus.billingReceived,
    billingImageUrl: "", // Not used since we're using static UI
    billingReceivedAt: DateTime.now(),
  );
}