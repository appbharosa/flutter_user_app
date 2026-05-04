import '../../domain/entities/order.dart';

// lib/data/models/order_model.dart
import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderType,
    required super.status,
    required super.message,
    this.bookingId,
  });

  final String? bookingId;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // The API returns result: { "booking_id": "BKID_0149" }
    final result = json['result'];
    final bookingId = result is Map ? result['booking_id'] : null;
    return OrderModel(
      id: 0, // not used – you can discard or generate a temporary ID
      orderType: '',
      status: '',
      message: json['message'] ?? '',
      bookingId: bookingId,
    );
  }
}