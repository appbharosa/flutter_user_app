import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String orderType;
  final String status;
  final String message;

  const Order({
    required this.id,
    required this.orderType,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [id, orderType, status];
}