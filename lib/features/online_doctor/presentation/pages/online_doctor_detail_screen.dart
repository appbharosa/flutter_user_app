import 'package:flutter/material.dart';
import 'package:user/core/utils/translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/online_doctor.dart';
import 'online_doctor_slot_screen.dart';

class OnlineDoctorDetailScreen extends StatelessWidget {
  final OnlineDoctor doctor;
  const OnlineDoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title:  Text('doctor_details'.tr(), style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.network(
                          doctor.image,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 80),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        doctor.specialization,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Qualification
                    _buildDetailRow('qualification'.tr(), doctor.qualification),
                    const SizedBox(height: 12),
                    _buildDetailRow('experience'.tr(), '${doctor.specialization} years'),
                    const SizedBox(height: 12),
                    _buildDetailRow('fee'.tr(), '₹${doctor.fee}'),
                    const SizedBox(height: 12),
                    _buildDetailRow('rating'.tr(), '${doctor.totalRating} (${doctor.totalReviews} reviews)'),
                    const SizedBox(height: 12),
                    if (doctor.availability == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:  Text(
                          'available_today'.tr(),
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400,fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnlineDoctorSlotScreen(doctor: doctor),
                        ),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:  Text(
                    'request_booking'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppColors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not specified',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}