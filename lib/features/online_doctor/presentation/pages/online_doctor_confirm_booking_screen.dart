import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/utils/translations.dart';
import 'package:user/features/online_doctor/presentation/pages/widgets/online_doctor_coupon_bottom_sheet.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/entities/online_doctor_slot.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../online_doctor_apply_coupon_bloc/online_doctor_apply_coupon_bloc.dart';
import '../online_doctor_booking_bloc/online_doctor_booking_bloc.dart';
import '../online_doctor_booking_bloc/online_doctor_booking_event.dart';
import '../online_doctor_booking_bloc/online_doctor_booking_state.dart';
import '../../../../core/di/injection.dart' as sl;


class OnlineDoctorConfirmBookingScreen extends StatefulWidget {
  final OnlineDoctor doctor;
  final String selectedDate;
  final String formattedDate;
  final OnlineDoctorSlot slot;
  final FamilyMember familyMember;
  final int bookingCount;

  const OnlineDoctorConfirmBookingScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.formattedDate,
    required this.slot,
    required this.familyMember,
    required this.bookingCount,
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
  bool get isFree => widget.bookingCount <= 5;

  @override
  void initState() {
    super.initState();
    _originalAmount = isFree ? 0 : widget.doctor.fee.toDouble();
    _finalAmount = _originalAmount;
    _applyCouponBloc = sl.sl<OnlineDoctorApplyCouponBloc>();
    _bookingBloc = sl.sl<OnlineDoctorBookingBloc>();
  }

  void _showCouponSheet() {
    if (isFree) return; // No coupon for free booking
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => OnlineDoctorCouponBottomSheet(
        onCouponSelected: (couponCode) => _applyCouponBloc.add(ApplyOnlineDoctorCoupon(couponCode, _originalAmount)),
        lang: lang,
      ),
    );
  }

  void _proceedWithPayment(String paymentType) {
    final bookingParams = {
      'speciality_id': widget.doctor.id,
      'doctor_id': widget.doctor.specialityId,
      'date': widget.selectedDate,
      'slot_id': widget.slot.slotId,
      'time': widget.slot.time,
      'family_member_id': widget.familyMember.id,
      'fee': isFree ? 0 : widget.doctor.fee,
      'consultation_fee': isFree ? 0 : widget.doctor.fee,
    };

    // 🔍 Debug log
    debugPrint("🟢 Booking Params: $bookingParams");
    debugPrint("🟢 Payment Type: $paymentType");
    debugPrint("🟢 Is Free Booking: $isFree");
    _bookingBloc.add(ProcessOnlineDoctorBooking(bookingParams: bookingParams, paymentType: paymentType));
  }

  void _bookNow() {
    _proceedWithPayment('free'); // For free booking, payment type can be 'free' or just 'wallet'
  }

  void _showPaymentOptions() {
    if (isFree) {
      _bookNow();
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
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

  Widget _buildDetailRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 14 : 13)),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : (isTotal ? AppColors.blue : null),
            fontSize: isTotal ? 14 : 13,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _applyCouponBloc),
        BlocProvider.value(value: _bookingBloc),
      ],
      child: BlocListener<OnlineDoctorApplyCouponBloc, OnlineDoctorApplyCouponState>(
        listener: (context, state) {
          if (state is OnlineDoctorApplyCouponSuccess) {
            setState(() {
              _discount = state.discountAmount;
              _finalAmount = state.finalAmount;
              _appliedCouponCode = state.couponCode;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 12), Expanded(child: Text('Coupon applied!'))]),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is OnlineDoctorApplyCouponError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            );
          }
        },
        child: BlocConsumer<OnlineDoctorBookingBloc, OnlineDoctorBookingState>(
          listener: (context, state) {
            if (state is OnlineDoctorBookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 20), SizedBox(width: 12), Expanded(child: Text('Booking successful!'))]),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => false);
            } else if (state is OnlineDoctorBookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
            }
          },
          builder: (context, state) {
            final isProcessing = state is OnlineDoctorBookingLoading;
            return SafeArea(
              bottom: true,
              top: false,
              child: Scaffold(
                appBar: AppBar(
                  title:  Text('confirm_booking'.tr(), style: TextStyle(color: AppColors.whiteColor, fontSize: 16.5, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
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
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(widget.doctor.image, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 70)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.doctor.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                                        const SizedBox(height: 4),
                                        Text(widget.doctor.specialization, style: const TextStyle(fontSize: 12, color: Colors.black)),
                                        const SizedBox(height: 4),
                                        Text('Fee: ${widget.doctor.fee}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Appointment details
                           Text('appointment_details'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildDetailRow('date'.tr(), widget.formattedDate),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('time'.tr(), widget.slot.time),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Patient details
                           Text('patient_details'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildDetailRow('name'.tr(), widget.familyMember.name),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('mobile'.tr(), widget.familyMember.mobile),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Payment summary
                           Text('payment_summary'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  isFree
                                      ? _buildDetailRow('consultation_fee'.tr(), 'FREE')
                                      : _buildDetailRow('Consultation Fee', '₹${_originalAmount.toStringAsFixed(2)}'),
                                  if (_appliedCouponCode != null && !isFree) ...[
                                    const Divider(),
                                    _buildDetailRow('Coupon Discount ($_appliedCouponCode)', '- ₹${_discount.toStringAsFixed(2)}', isDiscount: true),
                                  ],
                                  const Divider(),
                                  isFree
                                      ? _buildDetailRow('total_amount'.tr(), 'FREE', isTotal: true)
                                      : _buildDetailRow('total_amount'.tr(), '₹${_finalAmount.toStringAsFixed(2)}', isTotal: true),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Apply coupon button (only if not free)
                          if (!isFree)
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: _showCouponSheet,
                                icon: const Icon(Icons.local_offer),
                                label:  Text('apply_coupon'.tr()),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.blue),
                                  foregroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ),
                          const SizedBox(height: 32),

                          // Confirm button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isProcessing ? null : _showPaymentOptions,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: isProcessing
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(isFree ? 'Book Now' : 'confirm_and_pay'.tr(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    if (isProcessing) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}