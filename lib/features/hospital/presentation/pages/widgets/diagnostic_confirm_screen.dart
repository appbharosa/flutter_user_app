import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/address.dart';
import '../../../../../domain/entities/hospital_diagnostic_booking.dart';
import '../../../../../domain/repositories/address_repository.dart';
import '../../bloc/hospital_diagnostic_booking_bloc/hospital_diagnostic_booking_bloc.dart';
import '../../bloc/hospital_diagnostic_booking_bloc/hospital_diagnostic_booking_event.dart';
import '../../bloc/hospital_diagnostic_booking_bloc/hospital_diagnostic_booking_state.dart';

class HospitalDiagnosticConfirm extends StatefulWidget {
  final int hospitalId;
  final int addressId;
  final List<String> prescriptionPaths;
  final int familyMemberId;
  final String familyMemberName;

  const HospitalDiagnosticConfirm({
    Key? key,
    required this.hospitalId,
    required this.addressId,
    required this.prescriptionPaths,
    required this.familyMemberId,
    required this.familyMemberName,
  }) : super(key: key);

  @override
  State<HospitalDiagnosticConfirm> createState() => _HospitalDiagnosticConfirmState();
}

class _HospitalDiagnosticConfirmState extends State<HospitalDiagnosticConfirm> {
  late Future<Address?> _addressFuture;

  @override
  void initState() {
    super.initState();
    _addressFuture = _fetchAddress();
  }

  Future<Address?> _fetchAddress() async {
    final result = await di.sl<AddressRepository>().getAddresses();
    return result.fold(
          (failure) => null,
          (addresses) {
        // Find address by ID
        for (final addr in addresses) {
          if (addr.id == widget.addressId) {
            return addr;
          }
        }
        // If not found, return first available or null
        return addresses.isNotEmpty ? addresses.first : null;
      },
    );
  }

  String _formatAddress(Address address) {
    return '${address.address}, ${address.city}, ${address.state} - ${address.pincode}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HospitalDiagnosticBookingBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Confirm Diagnostic Booking',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocListener<HospitalDiagnosticBookingBloc, HospitalDiagnosticBookingState>(
          listener: (context, state) {
            if (state is HospitalDiagnosticSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 3),
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              });
            } else if (state is HospitalDiagnosticFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.error)),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          child: FutureBuilder<Address?>(
            future: _addressFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final address = snapshot.data;
              final addressDisplay = address != null
                  ? _formatAddress(address)
                  : 'Address not found (ID: ${widget.addressId})';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address card
                    _buildInfoCard(
                      icon: Icons.location_on,
                      iconColor: AppColors.blue,
                      title: 'Diagnostic Address',
                      subtitle: addressDisplay,
                    ),
                    const SizedBox(height: 16),

                    // Family member card
                    _buildInfoCard(
                      icon: Icons.person,
                      iconColor: Colors.green,
                      title: 'Family Member',
                      subtitle: '${widget.familyMemberName} (ID: ${widget.familyMemberId})',
                    ),
                    const SizedBox(height: 16),

                    // Prescriptions card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description, color: AppColors.blue, size: 22),
                                const SizedBox(width: 8),
                                const Text(
                                  'Prescriptions',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${widget.prescriptionPaths.length} file(s)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.blue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.prescriptionPaths.length,
                                itemBuilder: (context, index) {
                                  final path = widget.prescriptionPaths[index];
                                  final isPdf = path.toLowerCase().endsWith('.pdf');
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade100,
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: isPdf
                                        ? const Center(
                                      child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                                    )
                                        : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(File(path), fit: BoxFit.cover),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Confirm button
                    BlocBuilder<HospitalDiagnosticBookingBloc, HospitalDiagnosticBookingState>(
                      builder: (context, state) {
                        final isLoading = state is HospitalDiagnosticLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                              final booking = HospitalDiagnosticBooking(
                                mainDataId: widget.hospitalId,
                                addressId: widget.addressId,
                                imagePaths: widget.prescriptionPaths,
                                familyMemberId: widget.familyMemberId,
                                language: 'en', // Replace with dynamic language if needed
                              );
                              context
                                  .read<HospitalDiagnosticBookingBloc>()
                                  .add(SubmitHospitalDiagnosticEvent(booking));
                            },
                            child: isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
