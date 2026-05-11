import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_bloc.dart';
import '../diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_event.dart';
import '../diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_state.dart';


class DiagnosticBookingFetchDetailPage extends StatelessWidget {
  final String bookingId;
  const DiagnosticBookingFetchDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DiagnosticBookingFetchDetailBloc>()..add(LoadFetchBookingDetail(bookingId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<DiagnosticBookingFetchDetailBloc, DiagnosticBookingFetchDetailState>(
          builder: (context, state) {
            if (state is DiagnosticBookingFetchDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DiagnosticBookingFetchDetailLoaded) {
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
                            Image.network(detail.diagnosticsLogo, height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 60)),
                            const SizedBox(height: 8),
                            Text(detail.diagnosticsName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(detail.diagnosticsAddress),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Patient Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${detail.patientName}'),
                            Text('Mobile: ${detail.patientMobile}'),
                            Text('Email: ${detail.patientEmail}'),
                            Text('DOB: ${detail.patientDob}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Prescription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Image.network(detail.prescriptionUrl, height: 200, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => {/* download or view full */},
                              child: const Text('View Prescription'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Booking Status: ${detail.bookingStatus}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Created On: ${detail.createdOn}'),
                  ],
                ),
              );
            } else if (state is DiagnosticBookingFetchDetailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}