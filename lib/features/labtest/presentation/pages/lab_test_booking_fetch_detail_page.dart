import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../lab_test_booking_fetch_detail_bloc/lab_test_booking_fetch_detail_bloc.dart';
import '../lab_test_booking_fetch_detail_bloc/lab_test_booking_fetch_detail_event.dart';
import '../lab_test_booking_fetch_detail_bloc/lab_test_booking_fetch_detail_state.dart';


class LabTestBookingFetchDetailPage extends StatelessWidget {
  final String bookingId;
  const LabTestBookingFetchDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LabTestBookingFetchDetailBloc>()..add(LoadLabTestBookingDetail(bookingId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<LabTestBookingFetchDetailBloc, LabTestBookingFetchDetailState>(
          builder: (context, state) {
            if (state is LabTestBookingFetchDetailLoading) return const Center(child: CircularProgressIndicator());
            if (state is LabTestBookingFetchDetailError) return Center(child: Text(state.message));
            if (state is LabTestBookingFetchDetailLoaded) {
              final detail = state.detail;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Image.network(detail.labTestLogo, height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.science, size: 60)),
                            const SizedBox(height: 8),
                            Text(detail.labTestName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                            const SizedBox(height: 4),
                            Text(detail.labTestAddress, style: const TextStyle(fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Patient Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${detail.patientName}', style: const TextStyle(fontFamily: 'Poppins')),
                            Text('Mobile: ${detail.patientMobile}', style: const TextStyle(fontFamily: 'Poppins')),
                            Text('Email: ${detail.patientEmail}', style: const TextStyle(fontFamily: 'Poppins')),
                            Text('DOB: ${detail.patientDob}', style: const TextStyle(fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Prescription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Image.network(detail.prescriptionUrl, height: 200, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                            const SizedBox(height: 8),
                            TextButton(onPressed: () {}, child: const Text('View Prescription')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Booking Status: ${detail.bookingStatus}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    Text('Created On: ${detail.createdOn}', style: const TextStyle(fontFamily: 'Poppins')),
                    if (detail.completedDate != null) Text('Completed On: ${detail.completedDate}', style: const TextStyle(fontFamily: 'Poppins')),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}