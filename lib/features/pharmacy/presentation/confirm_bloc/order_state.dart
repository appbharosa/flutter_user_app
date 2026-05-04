
import 'package:equatable/equatable.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override List<Object> get props => [];
}

class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}
class OrderSuccess extends OrderState {
  final String message;
  const OrderSuccess(this.message);
}
class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
}