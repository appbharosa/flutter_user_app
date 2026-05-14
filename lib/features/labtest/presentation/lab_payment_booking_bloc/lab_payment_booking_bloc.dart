import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/create_lab_payment_booking_usecase.dart';
import 'lab_payment_booking_event.dart';
import 'lab_payment_booking_state.dart';




class LabPaymentBookingBloc extends Bloc<LabPaymentBookingEvent, LabPaymentBookingState> {
  final CreateLabPaymentBookingUseCase createBookingUseCase;

  LabPaymentBookingBloc({required this.createBookingUseCase}) : super(LabPaymentBookingInitial()) {
    on<BookLabTestPayment>(_onBook);
  }

  Future<void> _onBook(BookLabTestPayment event, Emitter<LabPaymentBookingState> emit) async {
    emit(LabPaymentBookingLoading());
    final result = await createBookingUseCase(CreateLabPaymentBookingParams(
      labTestId: event.labTestId,
      testId: event.testId,
      addressId: event.addressId,
      count: event.count,
      fee: event.fee,
      date: event.date,
      time: event.time,
      familyMemberId: event.familyMemberId,
      couponId: event.couponId,
      paymentType: event.paymentType,
      prescriptionPaths: event.prescriptionPaths,
      slotId: event.slotId,
      consultationFee: event.consultationFee,
      flatDiscount: event.flatDiscount,
      orderId: event.orderId,
    ));
    result.fold(
          (failure) => emit(LabPaymentBookingError(failure.message)),
          (response) => emit(LabPaymentBookingSuccess(response)),
    );
  }
}