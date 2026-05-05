import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:user/domain/entities/cashfree_order.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/payment_status.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

import '../../../../core/services/cashfree_service.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  late final PaymentBloc _paymentBloc;
  final CashfreeService _cashfree = CashfreeService();

  @override
  void initState() {
    super.initState();
    _paymentBloc = sl<PaymentBloc>();
  }

  void _createOrder() {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Enter valid amount', isError: true);
      return;
    }
    _paymentBloc.add(CreatePaymentOrder(amount));
  }

  void _startCashfreeCheckout(CashfreeOrder order) async {
    // Use SANDBOX for testing, change to PRODUCTION for live
    final environment = CFEnvironment.SANDBOX;

    await _cashfree.startPayment(
      orderId: order.orderId,
      paymentSessionId: order.paymentSessionId,
      environment: environment,
      onSuccess: (orderId) {
        // SDK says payment completed – now verify with backend
        _paymentBloc.add(CheckPaymentStatus(orderId));
      },
      onFailure: (error) {
        _showSnackBar('Payment initiation failed: $error', isError: true);
      },
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 70),
            child: const Text(' Wallet',style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,  // SemiBold
              fontFamily: 'Poppins',
            ),
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentOrderCreated) {
              _startCashfreeCheckout(state.order);
            } else if (state is PaymentStatusChecked) {
              if (state.status.status == PaymentResult.success) {
                _showSnackBar('Payment successful!', isError: false);
                Navigator.pop(context, true);
              } else if (state.status.status == PaymentResult.pending) {
                _showSnackBar('Payment processed. Please check order status later.', isError: false);
                Navigator.pop(context, true); // still go back
              } else {
                _showSnackBar('Payment failed. Please try again.', isError: true);
              }
            } else if (state is PaymentError) {
              _showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (INR)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Proceed to Pay', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}