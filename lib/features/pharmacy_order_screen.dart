import 'package:flutter/material.dart';
import 'package:user/features/waiting_for_acceptance_screen.dart';

import '../data/models/pharmacy_order.dart';
import '../data/models/pharmacy_order_status.dart' hide OrderStatus;
import 'billing_details_screen.dart';
import 'order_accepted_screen.dart';


class PharmacyOrderScreen extends StatefulWidget {
  const PharmacyOrderScreen({super.key});

  @override
  State<PharmacyOrderScreen> createState() => _PharmacyOrderScreenState();
}

class _PharmacyOrderScreenState extends State<PharmacyOrderScreen> {
  PharmacyOrder currentOrder = PharmacyOrder.waiting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy Order Status"),
        backgroundColor: Colors.blue,
      ),
      body: _buildScreenBasedOnStatus(),
    );
  }

  Widget _buildScreenBasedOnStatus() {
    switch (currentOrder.status) {
      case OrderStatus.waiting:
        return WaitingForAcceptanceScreen(
          onAccepted: () {
            setState(() {
              currentOrder = PharmacyOrder.accepted;
            });
          },
        );
      case OrderStatus.accepted:
        return OrderAcceptedScreen(
          onBillingReceived: () {
            setState(() {
              currentOrder = PharmacyOrder.billingReceived;
            });
          },
        );
      case OrderStatus.billingReceived:
        return BillingDetailsScreen(
       //   billingImageUrl: currentOrder.billingImageUrl!,
          onBackToHome: () {
            Navigator.pop(context);
          },
        );
      case OrderStatus.none:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}