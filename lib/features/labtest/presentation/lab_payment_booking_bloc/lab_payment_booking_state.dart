

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/lab_payment_booking_response.dart';

abstract class LabPaymentBookingState extends Equatable {
  const LabPaymentBookingState();
  @override List<Object> get props => [];
}

class LabPaymentBookingInitial extends LabPaymentBookingState {}
class LabPaymentBookingLoading extends LabPaymentBookingState {}
class LabPaymentBookingSuccess extends LabPaymentBookingState {
  final LabPaymentBookingResponse response;
  const LabPaymentBookingSuccess(this.response);
}
class LabPaymentBookingError extends LabPaymentBookingState {
  final String message;
  const LabPaymentBookingError(this.message);
}