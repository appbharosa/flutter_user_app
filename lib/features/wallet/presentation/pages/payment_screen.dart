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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
    final environment = CFEnvironment.SANDBOX;

    await _cashfree.startPayment(
      orderId: order.orderId,
      paymentSessionId: order.paymentSessionId,
      environment: environment,
      onSuccess: (orderId) {
        _paymentBloc.add(CheckPaymentStatus(orderId));
      },
      onFailure: (error) {
        _showSnackBar(
          'Payment initiation failed: $error',
          isError: true,
        );
      },
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor:
        isError ? Colors.red.shade400 : Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.blue.withOpacity(0.25),
          ),
        ),
        child: Text(
          "₹$amount",
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentBloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          title: const Text(
            'Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentOrderCreated) {
              _startCashfreeCheckout(state.order);
            } else if (state is PaymentStatusChecked) {
              if (state.status.status == PaymentResult.success) {
                _showSnackBar(
                  'Payment successful!',
                  isError: false,
                );
                Navigator.pop(context, true);
              } else if (state.status.status ==
                  PaymentResult.pending) {
                _showSnackBar(
                  'Payment processed. Please check status later.',
                  isError: false,
                );
                Navigator.pop(context, true);
              } else {
                _showSnackBar(
                  'Payment failed. Please try again.',
                  isError: true,
                );
              }
            } else if (state is PaymentError) {
              _showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                /// Top Blue Background
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.blue,
                        AppColors.blue.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                ),

                /// Main Content
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      /// Wallet Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff1E88E5),
                              Color(0xff42A5F5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: const [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Wallet Balance",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            Text(
                              "₹ 0.00",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// Payment Card
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Add Money",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Enter amount to add into your wallet",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// Amount Field
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.currency_rupee,
                                  color: AppColors.blue,
                                ),
                                hintText: "Enter Amount",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                filled: true,
                                fillColor:
                                const Color(0xffF5F7FB),
                                contentPadding:
                                const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder:
                                OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder:
                                OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: AppColors.blue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            /// Quick Amounts
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildQuickAmountChip("100"),
                                _buildQuickAmountChip("250"),
                                _buildQuickAmountChip("500"),
                                _buildQuickAmountChip("1000"),
                              ],
                            ),

                            const SizedBox(height: 34),

                            /// Pay Button
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: state is PaymentLoading
                                    ? null
                                    : _createOrder,
                                style:
                                ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                  AppColors.blue,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),
                                child: state is PaymentLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Text(
                                  "Proceed to Pay",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.w600,
                                    fontFamily:
                                    'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}