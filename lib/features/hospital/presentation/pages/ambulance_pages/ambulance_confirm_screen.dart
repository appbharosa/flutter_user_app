import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/services/language_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/address.dart';
import '../../../../../domain/repositories/address_repository.dart';
import '../../../../home/presentation/pages/home_page.dart';
import '../../ambulance_booking_bloc/ambulance_booking_bloc.dart';
import '../../ambulance_booking_bloc/ambulance_booking_event.dart';
import '../../ambulance_booking_bloc/ambulance_booking_state.dart';


class AmbulanceConfirmScreen extends StatefulWidget {
  final int hospitalId;
  final int addressId;
  final int familyMemberId;
  final String familyMemberName;

  const AmbulanceConfirmScreen({
    Key? key,
    required this.hospitalId,
    required this.addressId,
    required this.familyMemberId,
    required this.familyMemberName,
  }) : super(key: key);

  @override
  State<AmbulanceConfirmScreen> createState() => _AmbulanceConfirmScreenState();
}

class _AmbulanceConfirmScreenState extends State<AmbulanceConfirmScreen> {
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
        for (final addr in addresses) {
          if (addr.id == widget.addressId) {
            return addr;
          }
        }
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
      create: (context) => di.sl<AmbulanceBookingBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text(
            'Confirm Ambulance Booking',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocListener<AmbulanceBookingBloc, AmbulanceBookingState>(
          listener: (context, state) {
            if (state is AmbulanceBookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Booking successful! ID: ${state.bookingId}')),
                    ],
                  ),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 3),
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                );
              });
            } else if (state is AmbulanceBookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              final addressText = address != null
                  ? _formatAddress(address)
                  : 'Address not found (ID: ${widget.addressId})';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header chip
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
                          fontSize: 16,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hospital card
                    _buildInfoCard(
                      icon: Icons.local_hospital,
                      iconColor: AppColors.blue,
                      title: 'Hospital',
                      subtitle: 'ID: ${widget.hospitalId}',
                    ),
                    const SizedBox(height: 16),

                    // Address card
                    _buildInfoCard(
                      icon: Icons.location_on,
                      iconColor: AppColors.blue,
                      title: 'Delivery Address',
                      subtitle: addressText,
                    ),
                    const SizedBox(height: 16),

                    // Family member card
                    _buildInfoCard(
                      icon: Icons.person,
                      iconColor: Colors.green,
                      title: 'Family Member',
                      subtitle: '${widget.familyMemberName}',
                    ),
                    const SizedBox(height: 32),

                    // Confirm button
                    BlocBuilder<AmbulanceBookingBloc, AmbulanceBookingState>(
                      builder: (context, state) {
                        final isLoading = state is AmbulanceBookingLoading;
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
                                : () async {
                              final language = await LanguageService.getCurrentLanguage();
                              context.read<AmbulanceBookingBloc>().add(
                                SubmitAmbulanceBooking(
                                  language: language,
                                  mainDataId: widget.hospitalId,
                                ),
                              );
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
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