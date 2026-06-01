
import 'package:equatable/equatable.dart';

abstract class FreeLabBookingState extends Equatable {
  const FreeLabBookingState();
  @override
  List<Object?> get props => [];
}

class FreeLabBookingInitial extends FreeLabBookingState {}

class FreeLabBookingLoading extends FreeLabBookingState {}

class FreeLabOrderCreated extends FreeLabBookingState {
  final String orderId;
  final String paymentSessionId;
  const FreeLabOrderCreated({required this.orderId, required this.paymentSessionId});
  @override
  List<Object?> get props => [orderId, paymentSessionId];
}

class FreeLabBookingSuccess extends FreeLabBookingState {
  final String message;
  const FreeLabBookingSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class FreeLabBookingFailure extends FreeLabBookingState {
  final String message;
  const FreeLabBookingFailure(this.message);
  @override
  List<Object?> get props => [message];
}