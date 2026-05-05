import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/wallet/presentation/bloc/payment_event.dart';
import 'package:user/features/wallet/presentation/bloc/payment_state.dart';

import '../../../../domain/use_cases/check_payment_status_usecase.dart';
import '../../../../domain/use_cases/create_cashfree_order_usecase.dart';


class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateCashfreeOrderUseCase createOrderUseCase;
  final CheckPaymentStatusUseCase checkStatusUseCase;

  PaymentBloc({
    required this.createOrderUseCase,
    required this.checkStatusUseCase,
  }) : super(PaymentInitial()) {
    on<CreatePaymentOrder>(_onCreatePaymentOrder);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
  }

  Future<void> _onCreatePaymentOrder(CreatePaymentOrder event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await createOrderUseCase(event.amount);
    result.fold(
          (failure) => emit(PaymentError(failure.message)),
          (order) => emit(PaymentOrderCreated(order)),
    );
  }

  Future<void> _onCheckPaymentStatus(CheckPaymentStatus event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await checkStatusUseCase(event.orderId);
    result.fold(
          (failure) => emit(PaymentError(failure.message)),
          (status) => emit(PaymentStatusChecked(status)),
    );
  }
}