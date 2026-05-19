import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/online_doctor/presentation/pages/widgets/online_doctor_coupon_bottom_sheet.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/entities/online_doctor_slot.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../online_doctor_apply_coupon_bloc/online_doctor_apply_coupon_bloc.dart';


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
    _applyCouponBloc = sl<OnlineDoctorApplyCouponBloc>();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _applyCouponBloc,
      child: BlocListener<OnlineDoctorApplyCouponBloc, OnlineDoctorApplyCouponState>(
        listener: (context, state) {
          if (state is OnlineDoctorApplyCouponSuccess) {
            setState(() {
              _discount = state.discountAmount;
              _finalAmount = state.finalAmount;
              _couponApplied = true;
              _appliedCouponCode = state.couponCode;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon applied! You saved ₹${state.discountAmount.toStringAsFixed(2)}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is OnlineDoctorApplyCouponError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Confirm Booking',style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
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
                                Text(widget.doctor.name,style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,  // SemiBold
                                  fontFamily: 'Poppins',
                                ),),
                                Text(widget.doctor.specialization,style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,  // SemiBold
                                  fontFamily: 'Poppins',
                                ),),
                                Text('Fee: ₹${widget.doctor.fee}',style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,  // SemiBold
                                  fontFamily: 'Poppins',
                                ),),
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
                    color: AppColors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,  // SemiBold
                    fontFamily: 'Poppins',
                  ),),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildDetailRow('Date', widget.formattedDate,),
                          _buildDetailRow('Time', widget.slot.time),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Patient details
                  const Text('Patient Details', style: TextStyle(
                    color: AppColors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,  // SemiBold
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
                    color: AppColors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,  // SemiBold
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                      onPressed: () {
                        // Final booking API placeholder – to be implemented later
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking will be confirmed soon!'), backgroundColor: Colors.green),
                        );
                      },
                      child: const Text('Confirm & Pay', style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,  // SemiBold
                        fontFamily: 'Poppins',
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isDiscount ? Colors.green : null)),
        ],
      ),
    );
  }
}