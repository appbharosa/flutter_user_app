

import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override List<Object> get props => [];
}

class CreatePaymentOrder extends PaymentEvent {
  final int amount;
  const CreatePaymentOrder(this.amount);
}

class CheckPaymentStatus extends PaymentEvent {
  final String orderId;
  const CheckPaymentStatus(this.orderId);
}