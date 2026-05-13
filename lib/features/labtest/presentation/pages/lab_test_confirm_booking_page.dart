import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/labtest/presentation/pages/widgets/coupon_bottom_sheet.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../apply_lab_coupon_bloc/apply_lab_coupon_bloc.dart';
import '../apply_lab_coupon_bloc/apply_lab_coupon_event.dart';
import '../apply_lab_coupon_bloc/apply_lab_coupon_state.dart';
import '../lab_test_booking_bloc/lab_test_booking_bloc.dart';
import '../lab_test_booking_bloc/lab_test_booking_event.dart';
import '../lab_test_booking_bloc/lab_test_booking_state.dart';

class LabTestConfirmBookingPage extends StatefulWidget {
  final int labTestId;
  final String labTestAddress;
  final List<String> prescriptionPaths;
  final FamilyMember familyMember;
  final int slotId;
  final String slotTime;
  final String selectedDate;
  final String formattedDate;
  final int packageId;
  final String packageName;
  final String packageFasting;
  final String packageReportIn;
  final int personsCount;
  final double totalAmount;

  const LabTestConfirmBookingPage({
    super.key,
    required this.labTestId,
    required this.labTestAddress,
    required this.prescriptionPaths,
    required this.familyMember,
    required this.slotId,
    required this.slotTime,
    required this.selectedDate,
    required this.formattedDate,
    required this.packageId,
    required this.packageName,
    required this.packageFasting,
    required this.packageReportIn,
    required this.personsCount,
    required this.totalAmount,
  });

  @override
  State<LabTestConfirmBookingPage> createState() => _LabTestConfirmBookingPageState();
}

class _LabTestConfirmBookingPageState extends State<LabTestConfirmBookingPage> {
  double _displayAmount = 0;
  double _discount = 0;
  bool _couponApplied = false;
  String _appliedCouponCode = '';

  @override
  void initState() {
    super.initState();
    _displayAmount = widget.totalAmount;
  }

  void _showCouponSheet(BuildContext context) {
    final applyBloc = context.read<ApplyLabCouponBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => CouponBottomSheet(
        onCouponSelected: (couponCode) {
          // Check if the same coupon is already applied
          if (_couponApplied && _appliedCouponCode == couponCode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Coupon already applied!'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            return;
          }
          // Always send original total amount (subtotal)
          applyBloc.add(ApplyCoupon(couponCode, widget.totalAmount));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<LabTestBookingBloc>()),
        BlocProvider(create: (context) => sl<ApplyLabCouponBloc>()),
      ],
      child: BlocListener<ApplyLabCouponBloc, ApplyLabCouponState>(
        listener: (context, state) {
          if (state is ApplyCouponSuccess) {
            setState(() {
              _discount = state.discountAmount;
              _displayAmount = state.finalAmount;
              _couponApplied = true;
              _appliedCouponCode = state.couponCode;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon applied! You saved ₹${state.discountAmount.toStringAsFixed(2)}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is ApplyCouponError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            title: const Text('Confirm Booking',style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,  // SemiBold
              fontFamily: 'Poppins',
            )),
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: BlocConsumer<LabTestBookingBloc, LabTestBookingState>(
            listener: (context, state) {
              if (state is LabTestBookingSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking successful! ID: ${state.bookingId}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              } else if (state is LabTestBookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lab Address
                          _buildInfoCard(
                            icon: Icons.location_on,
                            title: 'Lab Centre',
                            content: widget.labTestAddress,
                            iconColor: AppColors.blue,
                          ),
                          const SizedBox(height: 20),
                          // Prescription Section
                          const Text('Prescription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          widget.prescriptionPaths.isEmpty
                              ? const Text('No prescription uploaded', style: TextStyle(color: Colors.grey))
                              : SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.prescriptionPaths.length,
                              itemBuilder: (context, index) {
                                final path = widget.prescriptionPaths[index];
                                final isPDF = path.toLowerCase().endsWith('.pdf');
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade100,
                                    border: Border.all(color: Colors.grey.shade300),
                                    image: !isPDF
                                        ? DecorationImage(
                                      image: FileImage(File(path)),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: isPDF
                                      ? const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red)
                                      : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Appointment Details
                          const Text('Appointment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildInfoCard(icon: Icons.calendar_today, title: 'Date', content: widget.formattedDate, iconColor: Colors.green),
                          const SizedBox(height: 12),
                          _buildInfoCard(icon: Icons.access_time, title: 'Time Slot', content: widget.slotTime, iconColor: Colors.orange),
                          const SizedBox(height: 24),
                          // Package Details
                          const Text('Package Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildInfoCard(icon: Icons.medical_services, title: 'Package', content: widget.packageName, iconColor: Colors.purple),
                          const SizedBox(height: 8),
                          _buildInfoRow('Fasting Required', widget.packageFasting),
                          _buildInfoRow('Report Delivery', '${widget.packageReportIn} days'),
                          _buildInfoRow('Number of Persons', widget.personsCount.toString()),
                          const SizedBox(height: 24),
                          // Payment Summary
                          const Text('Payment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildInfoCard(icon: Icons.currency_rupee, title: 'Total Amount', content: '₹${widget.totalAmount.toStringAsFixed(2)}', iconColor: Colors.green),
                          if (_couponApplied) ...[
                            const SizedBox(height: 8),
                            _buildInfoCard(icon: Icons.local_offer, title: 'Coupon Discount', content: '- ₹${_discount.toStringAsFixed(2)}', iconColor: Colors.orange),
                            const SizedBox(height: 8),
                            _buildInfoCard(icon: Icons.currency_rupee, title: 'Final Amount', content: '₹${_displayAmount.toStringAsFixed(2)}', iconColor: Colors.red),
                          ],
                          const SizedBox(height: 16),
                          // Apply Coupon Button
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showCouponSheet(context),
                                  icon: const Icon(Icons.local_offer, size: 18),
                                  label: const Text('Apply Coupon'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: BorderSide(color: AppColors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Patient Details
                          const Text('Patient Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildInfoCard(icon: Icons.person, title: 'Name', content: widget.familyMember.name, iconColor: Colors.teal),
                          const SizedBox(height: 8),
                          _buildInfoCard(icon: Icons.phone, title: 'Mobile', content: widget.familyMember.mobile, iconColor: Colors.teal),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: state is LabTestBookingLoading
                            ? null
                            : () {
                          context.read<LabTestBookingBloc>().add(
                            BookLabTest(
                              labTestId: widget.labTestId,
                              prescriptionPaths: widget.prescriptionPaths,
                              lang: lang,
                              familyMemberId: widget.familyMember.id,
                              // slotId: widget.slotId,
                              // packageId: widget.packageId,
                              // personsCount: widget.personsCount,
                              // totalAmount: _displayAmount,
                            ),
                          );
                        },
                        child: state is LabTestBookingLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Confirm & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String content, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: iconColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: TextStyle(
                  color: AppColors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,  // SemiBold
                  fontFamily: 'Poppins',
                )),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: AppColors.black,
            fontSize: 12,
            fontWeight: FontWeight.w400,  // SemiBold
            fontFamily: 'Poppins',
          )),
          Text(value,style: TextStyle(
            color: AppColors.black,
            fontSize: 12,
            fontWeight: FontWeight.w400,  // SemiBold
            fontFamily: 'Poppins',
          )),
        ],
      ),
    );
  }
}