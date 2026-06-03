import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/services/cashfree_service.dart';
import '../../../../../core/appurls/app_urls.dart';
import 'doctor_booking_event.dart';
import 'doctor_booking_state.dart';


class DoctorBookingBloc extends Bloc<DoctorBookingEvent, DoctorBookingState> {
  final DioClient dioClient;
  final CashfreeService cashfreeService;

  DoctorBookingBloc({required this.dioClient, required this.cashfreeService})
      : super(DoctorBookingInitial()) {
    on<ProcessDoctorBooking>(_onProcessBooking);
  }

  Future<void> _onProcessBooking(ProcessDoctorBooking event, Emitter<DoctorBookingState> emit) async {
    emit(DoctorBookingLoading());
    try {
      // Step 1: Create order (get payment_session_id and order_id)
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

      // Step 2: If payment type is online, initiate Cashfree payment
      if (event.paymentType == 'online') {
        final paymentSuccess = await _processOnlinePayment(orderId, paymentSessionId);
        if (!paymentSuccess) {
          emit(DoctorBookingFailure('Payment failed or cancelled'));
          return;
        }
      }

      // Step 3: Call doctor booking API with transaction_id (order_id)
      final bookingParams = Map<String, dynamic>.from(event.bookingParams);
      bookingParams['transaction_id'] = orderId;
      bookingParams['payment_type'] = event.paymentType;

      final bookingResponse = await dioClient.dio.post(
        AppUrls.hospitalDoctorPayment,
        data: bookingParams,
      );
      if (bookingResponse.data['status'] == 200) {
        emit(DoctorBookingSuccess(bookingResponse.data['message'] ?? 'Booking successful'));
      } else {
        emit(DoctorBookingFailure(bookingResponse.data['message'] ?? 'Booking failed'));
      }
    } catch (e) {
      emit(DoctorBookingFailure(e.toString()));
    }
  }

  Future<bool> _processOnlinePayment(String orderId, String paymentSessionId) async {
    final completer = Completer<bool>();
    try {
      cashfreeService.startPayment(
        orderId: orderId,
        paymentSessionId: paymentSessionId,
        environment: CFEnvironment.PRODUCTION, // Change to PRODUCTION for live
        onSuccess: (orderId) {
          completer.complete(true);
        },
        onFailure: (error) {
          completer.complete(false);
        },
      );
    } catch (e) {
      return false;
    }
    return await completer.future;
  }
}