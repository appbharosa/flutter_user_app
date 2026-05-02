// lib/features/home/presentation/tabs/home_tab.dart
import 'package:flutter/material.dart';

// lib/features/home/presentation/tabs/home_tab.dart
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // First row: Online Doctors & Offline Doctors
          Row(
            children: [
              _buildServiceCard(
                title: 'Online Doctors',
                imagePath: 'assets/online_doctor.jpeg',
                onTap: () {
                  // Add navigation later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Online Doctors tapped')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildServiceCard(
                title: 'Offline Doctors',
                imagePath: 'assets/offline_doctor.jpg',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offline Doctors tapped')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Second row: Pharmacy & Diagnostic
          Row(
            children: [
              _buildServiceCard(
                title: 'Pharmacy',
                imagePath: 'assets/pharmacy.jpeg',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pharmacy tapped')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildServiceCard(
                title: 'Diagnostic',
                imagePath: 'assets/pharmacy.jpeg',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diagnostic tapped')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // You can add more sections below (e.g., banners, offers)
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
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