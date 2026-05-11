import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class WaitingForAcceptanceScreen extends StatelessWidget {
  final VoidCallback onAccepted;

  const WaitingForAcceptanceScreen({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            "Waiting for Pharmacy to Accept Your Order",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "We'll notify you once the pharmacy accepts your prescription.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onAccepted,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "Simulate Acceptance",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}