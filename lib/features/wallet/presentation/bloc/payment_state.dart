

import 'package:equatable/equatable.dart';
import 'package:user/domain/entities/cashfree_order.dart';

import '../../../../domain/entities/payment_status.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}
class PaymentOrderCreated extends PaymentState {
  final CashfreeOrder order;
  const PaymentOrderCreated(this.order);
}
class PaymentStatusChecked extends PaymentState {
  final PaymentStatus status;
  const PaymentStatusChecked(this.status);
}
class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
}

class WalletBalanceLoaded extends PaymentState { // ✅ NEW
  final double balance;
  const WalletBalanceLoaded(this.balance);
}
