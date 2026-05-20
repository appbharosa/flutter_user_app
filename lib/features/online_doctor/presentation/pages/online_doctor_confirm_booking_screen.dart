import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/online_doctor/presentation/pages/widgets/online_doctor_coupon_bottom_sheet.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/entities/online_doctor_slot.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../online_doctor_apply_coupon_bloc/online_doctor_apply_coupon_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/cashfree_service.dart';
import '../online_doctor_booking_bloc/online_doctor_booking_bloc.dart';
import '../online_doctor_booking_bloc/online_doctor_booking_event.dart';
import '../online_doctor_booking_bloc/online_doctor_booking_state.dart';

class OnlineDoctorConfirmBookingScreen extends StatefulWidget {
  final OnlineDoctor doctor;
  final String selectedDate;
  final String formattedDate;
  final OnlineDoctorSlot slot;
  final FamilyMember familyMember;

  const OnlineDoctorConfirmBookingScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.formattedDate,
    required this.slot,
    required this.familyMember,
  });

  @override
  State<OnlineDoctorConfirmBookingScreen> createState() => _OnlineDoctorConfirmBookingScreenState();
}

class _OnlineDoctorConfirmBookingScreenState extends State<OnlineDoctorConfirmBookingScreen> {
  late OnlineDoctorApplyCouponBloc _applyCouponBloc;
  late OnlineDoctorBookingBloc _bookingBloc;
  double _originalAmount = 0;
  double _discount = 0;
  double _finalAmount = 0;
  String? _appliedCouponCode;
  bool _couponApplied = false;

  @override
  void initState() {
    super.initState();
    _originalAmount = widget.doctor.fee.toDouble();
    _finalAmount = _originalAmount;
    _applyCouponBloc = di.sl<OnlineDoctorApplyCouponBloc>();
    _bookingBloc = di.sl<OnlineDoctorBookingBloc>();
  }

  void _showCouponSheet() {
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => OnlineDoctorCouponBottomSheet(
        onCouponSelected: (couponCode) {
          _applyCouponBloc.add(ApplyOnlineDoctorCoupon(couponCode, _originalAmount));
        },
        lang: lang,
      ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: AppColors.blue),
              title: const Text('Wallet'),
              onTap: () {
                Navigator.pop(context);
                _proceedWithPayment('wallet');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.blue),
              title: const Text('Online Payment'),
              onTap: () {
                Navigator.pop(context);
                _proceedWithPayment('online');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _proceedWithPayment(String paymentType) {
    final bookingParams = {
      'speciality_id': widget.doctor.specialityId,
      'doctor_id': widget.doctor.id,
      'date': widget.selectedDate,
      'slot_id': widget.slot.slotId,
      'time': widget.slot.time,
      'family_member_id': widget.familyMember.id,
      'fee': widget.doctor.fee,
      'consultation_fee': widget.doctor.fee,
    //  'address_id': 0, // Online doctor may not need address; adjust if needed
    };
    _bookingBloc.add(ProcessOnlineDoctorBooking(bookingParams: bookingParams, paymentType: paymentType));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _applyCouponBloc),
        BlocProvider.value(value: _bookingBloc),
      ],
      child: BlocConsumer<OnlineDoctorBookingBloc, OnlineDoctorBookingState>(
        listener: (context, state) {
          if (state is OnlineDoctorBookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(child: Text('Booking successful!')),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
            );
          } else if (state is OnlineDoctorBookingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isProcessing = state is OnlineDoctorBookingLoading;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Confirm Booking', style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              )),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor details
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(widget.doctor.image, width: 60, height: 60, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.doctor.name, style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    )),
                                    Text(widget.doctor.specialization, style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    )),
                                    Text('Fee: ₹${widget.doctor.fee}', style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Appointment details
                      const Text('Appointment Details', style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      )),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _buildDetailRow('Date', widget.formattedDate),
                              _buildDetailRow('Time', widget.slot.time),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Patient details
                      const Text('Patient Details', style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      )),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _buildDetailRow('Name', widget.familyMember.name),
                              _buildDetailRow('Mobile', widget.familyMember.mobile),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment summary
                      const Text('Payment Summary', style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      )),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _buildDetailRow('Consultation Fee', '₹${_originalAmount.toStringAsFixed(2)}'),
                              if (_couponApplied) ...[
                                const Divider(),
                                _buildDetailRow('Coupon Discount', '- ₹${_discount.toStringAsFixed(2)}', isDiscount: true),
                                _buildDetailRow('Total Amount', '₹${_finalAmount.toStringAsFixed(2)}', isTotal: true),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Apply coupon button
                      OutlinedButton.icon(
                        onPressed: _showCouponSheet,
                        icon: const Icon(Icons.local_offer),
                        label: const Text('Apply Coupon'),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.blue)),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isProcessing ? null : _showPaymentOptions,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                          child: isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Confirm & Pay', style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : null,
          )),
        ],
      ),
    );
  }
}