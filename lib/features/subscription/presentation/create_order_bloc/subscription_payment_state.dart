

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/subscription_order.dart';

abstract class SubscriptionPaymentState extends Equatable {
  const SubscriptionPaymentState();
  @override List<Object> get props => [];
}

class SubscriptionPaymentInitial extends SubscriptionPaymentState {}
class SubscriptionPaymentLoading extends SubscriptionPaymentState {}
class SubscriptionPaymentOrderCreated extends SubscriptionPaymentState {
  final SubscriptionOrder order;
  final int subscriptionId;
  const SubscriptionPaymentOrderCreated(this.order, this.subscriptionId);
}
class SubscriptionPaymentSuccess extends SubscriptionPaymentState {}
class SubscriptionPaymentError extends SubscriptionPaymentState {
  final String message;
  const SubscriptionPaymentError(this.message);
}