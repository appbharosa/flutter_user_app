

import 'package:equatable/equatable.dart';

abstract class SubscriptionPaymentEvent extends Equatable {
  const SubscriptionPaymentEvent();
  @override List<Object> get props => [];
}

class CreateSubscriptionPaymentOrder extends SubscriptionPaymentEvent {
  final int amount;
  final int subscriptionId;
  const CreateSubscriptionPaymentOrder(this.amount, this.subscriptionId);
}

class ConfirmSubscriptionPayment extends SubscriptionPaymentEvent {
  final String orderId;
  final int subscriptionId;
  const ConfirmSubscriptionPayment(this.orderId, this.subscriptionId);
}