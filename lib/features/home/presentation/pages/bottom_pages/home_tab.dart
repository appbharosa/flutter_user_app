// lib/features/home/presentation/tabs/home_tab.dart
import 'package:flutter/material.dart';

// lib/features/home/presentation/tabs/home_tab.dart
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// Row 1
          Row(
            children: [
              _buildServiceCard(
                title: 'Online Doctors',
                lottiePath: 'assets/animations/online_doctor.json',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Online Doctors tapped')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildServiceCard(
                title: 'Offline Doctors',
                lottiePath: 'assets/animations/health.json',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offline Doctors tapped')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Row 2
          Row(
            children: [
              _buildServiceCard(
                title: 'Pharmacy',
                lottiePath: 'assets/animations/pharmacy.json',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pharmacy tapped')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildServiceCard(
                title: 'Diagnostic',
                lottiePath: 'assets/animations/diagnostic.json',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diagnostic tapped')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String lottiePath,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              /// 🔥 LOTTIE ANIMATION
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Lottie.asset(
                    lottiePath,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),

              /// TITLE
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}