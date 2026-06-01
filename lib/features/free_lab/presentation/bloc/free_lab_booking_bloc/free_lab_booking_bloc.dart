import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../core/appurls/app_urls.dart';
import '../../../../../core/network/dio_client.dart';
import 'free_lab_booking_event.dart';
import 'free_lab_booking_state.dart';



class FreeLabBookingBloc extends Bloc<FreeLabBookingEvent, FreeLabBookingState> {
  final DioClient dioClient;

  FreeLabBookingBloc({required this.dioClient}) : super(FreeLabBookingInitial()) {
    on<CreateFreeLabOrder>(_onCreateOrder);
    on<SubmitFreeLabBooking>(_onSubmitBooking);
  }

  Future<void> _onCreateOrder(CreateFreeLabOrder event, Emitter<FreeLabBookingState> emit) async {
    emit(FreeLabBookingLoading());
    try {
      debugPrint("🔵 Creating Cashfree order with amount: ${event.amount}, currency: ${event.currency}");

      final response = await dioClient.dio.post(
        AppUrls.labCreateCashfreeOrder,
        data: {
          'amount': event.amount,
          'currency': event.currency,
        },
      );

      debugPrint("📦 Create order response: ${response.data}");

      // Check for different status formats
      final status = response.data['status'];
      if (status == 'success' || status == 200) {
        final data = response.data['data'];
        final orderId = data['order_id'];
        final paymentSessionId = data['payment_session_id'];

        debugPrint("✅ Order created successfully - Order ID: $orderId, Session ID: $paymentSessionId");

        emit(FreeLabOrderCreated(
          orderId: orderId,
          paymentSessionId: paymentSessionId,
        ));
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to create order';
        debugPrint("❌ Create order failed: $errorMsg");
        emit(FreeLabBookingFailure(errorMsg));
      }
    } catch (e) {
      debugPrint("❌ Exception in create order: $e");
      emit(FreeLabBookingFailure(e.toString()));
    }
  }

  Future<void> _onSubmitBooking(SubmitFreeLabBooking event, Emitter<FreeLabBookingState> emit) async {
    try {
      debugPrint("🔵 Submitting booking with data: ${event.bookingData}");
      debugPrint("🔵 Language: ${event.language}");

      // Ensure order_id is present
      if (event.bookingData['order_id'] == null || event.bookingData['order_id'].isEmpty) {
        final errorMsg = "Order ID is missing";
        debugPrint("❌ $errorMsg");
        emit(FreeLabBookingFailure(errorMsg));
        return;
      }

      debugPrint("✅ Order ID being sent: ${event.bookingData['order_id']}");

      final response = await dioClient.dio.post(
        AppUrls.freeLabPayment,
        queryParameters: {'lang': event.language},
        data: event.bookingData,
      );

      debugPrint("📦 Booking response: ${response.data}");

      if (response.data['status'] == 200) {
        debugPrint("✅ Booking successful: ${response.data['message']}");
        emit(FreeLabBookingSuccess(response.data['message'] ?? 'Booking successful'));
      } else {
        final errorMsg = response.data['message'] ?? 'Booking failed';
        debugPrint("❌ Booking failed: $errorMsg");
        emit(FreeLabBookingFailure(errorMsg));
      }
    } catch (e) {
      debugPrint("❌ Exception in booking: $e");
      emit(FreeLabBookingFailure(e.toString()));
    }
  }
}