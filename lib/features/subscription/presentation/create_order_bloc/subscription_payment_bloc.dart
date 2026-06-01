import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/subscription/presentation/create_order_bloc/subscription_payment_event.dart';
import 'package:user/features/subscription/presentation/create_order_bloc/subscription_payment_state.dart';
import '../../../../core/services/cashfree_service.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

import '../../../../domain/use_cases/create_subscription_order_usecase.dart';
import '../../../../domain/use_cases/submit_subscription_usecase.dart';



class SubscriptionPaymentBloc extends Bloc<SubscriptionPaymentEvent, SubscriptionPaymentState> {
  final CreateSubscriptionOrderUseCase createOrderUseCase;
  final SubmitSubscriptionUseCase submitSubscriptionUseCase;
  final CashfreeService cashfreeService;

  SubscriptionPaymentBloc({
    required this.createOrderUseCase,
    required this.submitSubscriptionUseCase,
    required this.cashfreeService,
  }) : super(SubscriptionPaymentInitial()) {
    on<CreateSubscriptionPaymentOrder>(_onCreateOrder);
    on<ConfirmSubscriptionPayment>(_onConfirmPayment);
  }

  Future<void> _onCreateOrder(CreateSubscriptionPaymentOrder event, Emitter<SubscriptionPaymentState> emit) async {
    debugPrint("🔵 CreateSubscriptionPaymentOrder - amount: ${event.amount}, subscriptionId: ${event.subscriptionId}");
    emit(SubscriptionPaymentLoading());
    final result = await createOrderUseCase(event.amount);
    result.fold(
          (failure) {
        debugPrint("❌ Create order failure: ${failure.message}");
        emit(SubscriptionPaymentError(failure.message));
      },
          (order) {
        debugPrint("✅ Order created - orderId: ${order.orderId}");
        emit(SubscriptionPaymentOrderCreated(order, event.subscriptionId));
      },
    );
  }

  Future<void> _onConfirmPayment(ConfirmSubscriptionPayment event, Emitter<SubscriptionPaymentState> emit) async {
    debugPrint("🔵 ConfirmSubscriptionPayment - orderId: ${event.orderId}, subscriptionId: ${event.subscriptionId}");
    emit(SubscriptionPaymentLoading());
    final result = await submitSubscriptionUseCase(event.orderId, event.subscriptionId);
    result.fold(
          (failure) {
        debugPrint("❌ Confirm payment failure: ${failure.message}");
        emit(SubscriptionPaymentError(failure.message));
      },
          (_) {
        debugPrint("✅ Confirm payment success");
        emit(SubscriptionPaymentSuccess());
      },
    );
  }
}