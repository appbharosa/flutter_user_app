import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/create_order_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';


class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;

  OrderBloc({required this.createOrderUseCase}) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await createOrderUseCase(CreateOrderParams(
      pharmacyId: event.pharmacyId,
      orderType: event.orderType,
      prescriptionPaths: event.prescriptionPaths,
      lang: event.lang,
      addressId: event.addressId,
    ));
    result.fold(
          (failure) => emit(OrderError(failure.message)),
          (order) => emit(OrderSuccess('Order placed successfully!')),
    );
  }
}