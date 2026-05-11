import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/subscription_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../create_order_bloc/subscription_payment_bloc.dart';
import '../create_order_bloc/subscription_payment_event.dart';
import '../../../../core/services/cashfree_service.dart';
import '../../../../domain/entities/subscription_order.dart'; // make sure this exists
import '../create_order_bloc/subscription_payment_state.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SubscriptionBloc>()..add(LoadSubscriptionPlans())),
        BlocProvider(create: (context) => sl<SubscriptionPaymentBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscription Plans'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SubscriptionLoaded) {
              if (state.plans.isEmpty) {
                return const Center(child: Text('No plans available'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Choose your plan',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 640,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: state.plans.length,
                      itemBuilder: (context, index) {
                        final plan = state.plans[index];
                        return _buildPlanCard(context, plan);
                      },
                    ),
                  ),
                ],
              );
            } else if (state is SubscriptionError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan) {
    return GestureDetector(
      onTap: () => _showPriceBottomSheet(context, plan),
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F52A5), Color(0xFF4CAF50), Color(0xFFFFD54F)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(plan.duration, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('₹${plan.finalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      if (plan.price > plan.finalPrice) ...[
                        const SizedBox(width: 8),
                        Text('₹${plan.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            /// BENEFITS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: plan.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(benefit, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            /// BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showPriceBottomSheet(context, plan),
                  child: const Text("View Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceBottomSheet(BuildContext context, SubscriptionPlan plan) {
    final paymentBloc = context.read<SubscriptionPaymentBloc>();
    final amount = plan.totalAmount.ceil();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return BlocProvider.value(
          value: paymentBloc,
          child: BlocConsumer<SubscriptionPaymentBloc, SubscriptionPaymentState>(
            listener: (context, state) {
              if (state is SubscriptionPaymentOrderCreated) {
                Navigator.pop(context); // close bottom sheet
                _openCashfreeCheckout(context, state.order, state.subscriptionId, paymentBloc);
              } else if (state is SubscriptionPaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              } else if (state is SubscriptionPaymentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription successful!'), backgroundColor: Colors.green),
                );
                Navigator.popUntil(context, (route) => route.isFirst); // go back to home
              }
            },
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Plan', plan.name),
                    _buildDetailRow('Subtotal', '₹${plan.finalPrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Persons Covered', plan.personsCovered.toString()),
                    _buildDetailRow('GST (18%)', '₹${plan.gstAmount.toStringAsFixed(2)}'),
                    const Divider(height: 32, thickness: 1),
                    _buildDetailRow('Total Amount', '₹${plan.totalAmount.toStringAsFixed(2)}', isTotal: true),
                    const SizedBox(height: 24),
                    state is SubscriptionPaymentLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          paymentBloc.add(CreateSubscriptionPaymentOrder(amount, plan.id));
                        },
                        child: const Text(
                          'Subscribe Now',
                          style: TextStyle(color: AppColors.whiteColor, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openCashfreeCheckout(BuildContext context, SubscriptionOrder order, int subscriptionId, SubscriptionPaymentBloc bloc) {
    final cashfree = sl<CashfreeService>();
    cashfree.startPayment(
      orderId: order.orderId,
      paymentSessionId: order.paymentSessionId,
      environment: CFEnvironment.SANDBOX,
      onSuccess: (orderId) {
        bloc.add(ConfirmSubscriptionPayment(orderId, subscriptionId));
      },
      onFailure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}