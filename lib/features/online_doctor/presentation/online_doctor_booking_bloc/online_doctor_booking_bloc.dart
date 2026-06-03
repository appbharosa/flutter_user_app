import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/services/cashfree_service.dart';
import '../../../../../core/appurls/app_urls.dart';
import 'online_doctor_booking_event.dart';
import 'online_doctor_booking_state.dart';


class OnlineDoctorBookingBloc extends Bloc<OnlineDoctorBookingEvent, OnlineDoctorBookingState> {
  final DioClient dioClient;
  final CashfreeService cashfreeService;

  OnlineDoctorBookingBloc({required this.dioClient, required this.cashfreeService})
      : super(OnlineDoctorBookingInitial()) {
    on<ProcessOnlineDoctorBooking>(_onProcessBooking);
  }

  Future<void> _onProcessBooking(ProcessOnlineDoctorBooking event, Emitter<OnlineDoctorBookingState> emit) async {
    emit(OnlineDoctorBookingLoading());
    try {
      // Step 1: Create order
      final createOrderResponse = await dioClient.dio.post(
        AppUrls.createOrder,
        data: {
          'amount': event.bookingParams['consultation_fee'],
          'currency': 'INR',
        },
      );
      if (createOrderResponse.data['status'] != 'success' &&
          createOrderResponse.data['status'] != 200) {
        throw Exception(createOrderResponse.data['message'] ?? 'Failed to create order');
      }
      final orderData = createOrderResponse.data['data'];
      final paymentSessionId = orderData['payment_session_id'];
      final orderId = orderData['order_id'];

      // Step 2: If online, process Cashfree payment
      if (event.paymentType == 'online') {
        final paymentSuccess = await _processOnlinePayment(orderId, paymentSessionId);
        if (!paymentSuccess) {
          emit(OnlineDoctorBookingFailure('Payment failed or cancelled'));
          return;
        }
      }

      // Step 3: Final booking API
      final bookingParams = Map<String, dynamic>.from(event.bookingParams);
      bookingParams['transaction_id'] = orderId;
      bookingParams['payment_type'] = event.paymentType;

      final bookingResponse = await dioClient.dio.post(
        AppUrls.onlineDoctorPayment,
        data: bookingParams,
      );
      if (bookingResponse.data['status'] == 200) {
        emit(OnlineDoctorBookingSuccess(bookingResponse.data['message'] ?? 'Booking successful'));
      } else {
        emit(OnlineDoctorBookingFailure(bookingResponse.data['message'] ?? 'Booking failed'));
      }
    } catch (e) {
      emit(OnlineDoctorBookingFailure(e.toString()));
    }
  }

  Future<bool> _processOnlinePayment(String orderId, String paymentSessionId) async {
    final completer = Completer<bool>();
    try {
      cashfreeService.startPayment(
        orderId: orderId,
        paymentSessionId: paymentSessionId,
        environment: CFEnvironment.PRODUCTION, // Change to PRODUCTION for live
        onSuccess: (orderId) => completer.complete(true),
        onFailure: (error) => completer.complete(false),
      );
    } catch (e) {
      return false;
    }
    return await completer.future;
  }
}