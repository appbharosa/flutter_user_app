import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';


import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';


class CashfreeService {
  static final CashfreeService _instance = CashfreeService._internal();
  factory CashfreeService() => _instance;
  CashfreeService._internal();

  final CFPaymentGatewayService _paymentService = CFPaymentGatewayService();
  String? _currentOrderId;

  void initialize() {

  }

  Future<void> startPayment({
    required String orderId,
    required String paymentSessionId,
    required CFEnvironment environment,
    required Function(String orderId) onSuccess,
    required Function(String error) onFailure,
  }) async {
    _currentOrderId = orderId;


    _paymentService.setCallback(
          (String orderId) {
            print("✅ Cashfree success callback for order $orderId");
        onSuccess(orderId);
      },
          (CFErrorResponse errorResponse, String orderId) {
        // 支付流程出错
        onFailure(errorResponse.getMessage() ?? 'Payment failed');
      },
    );

    try {
      final session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#2196F3")
          .setNavigationBarTextColor("#FFFFFF")
          .setPrimaryFont("Poppins")
          .build();

      final webCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();

      await _paymentService.doPayment(webCheckout);
    } catch (e) {
      onFailure(e.toString());
    }
  }
}