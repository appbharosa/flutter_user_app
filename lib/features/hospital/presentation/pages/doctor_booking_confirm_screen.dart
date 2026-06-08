
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/doctor_coupon.dart';
import '../../../../domain/entities/hospital_doctor.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../doctor_booking_bloc/doctor_booking_bloc.dart';
import '../doctor_booking_bloc/doctor_booking_event.dart';
import '../doctor_booking_bloc/doctor_booking_state.dart';
import '../doctor_coupon_bloc/doctor_coupon_bloc.dart';


class DoctorBookingConfirmScreen extends StatefulWidget {
  final HospitalDoctor doctor;
  final int hospitalId;
  final int addressId;
  final int slotId;
  final String slotTime;
  final String date;
  final String formattedDate;
  final int consultationFee;
  final int familyMemberId;
  final String familyMemberName;

  const DoctorBookingConfirmScreen({
    Key? key,
    required this.doctor,
    required this.hospitalId,
    required this.addressId,
    required this.slotId,
    required this.slotTime,
    required this.date,
    required this.formattedDate,
    required this.consultationFee,
    required this.familyMemberId,
    required this.familyMemberName,
  }) : super(key: key);

  @override
  State<DoctorBookingConfirmScreen> createState() => _DoctorBookingConfirmScreenState();
}

class _DoctorBookingConfirmScreenState extends State<DoctorBookingConfirmScreen> {
  late DoctorCouponBloc _couponBloc;
  late DoctorBookingBloc _bookingBloc;
  int _originalFee = 0;
  int _discountedFee = 0;
  String? _appliedCouponCode;
  String? _appliedCouponId;

  @override
  void initState() {
    super.initState();
    _originalFee = widget.consultationFee;
    _discountedFee = widget.consultationFee;
    _couponBloc = di.sl<DoctorCouponBloc>();
    _bookingBloc = di.sl<DoctorBookingBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoupons();
    });
  }

  Future<void> _loadCoupons() async {
    final language = await LanguageService.getCurrentLanguage();
    _couponBloc.add(LoadDoctorCoupons(language));
  }

  void _applyCoupon(DoctorCoupon coupon) async {
    // Close bottom sheet if open
    if (Navigator.canPop(context)) Navigator.pop(context);
    final language = await LanguageService.getCurrentLanguage();
    _couponBloc.add(ApplyDoctorCoupon(
      couponCode: coupon.name,
      subtotal: _originalFee,
      language: language,
    ));
  }

  void _showCouponBottomSheet() {
    // Ensure previous sheet is closed before opening a new one
    if (ModalRoute.of(context)?.isCurrent != true) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocBuilder<DoctorCouponBloc, DoctorCouponState>(
        bloc: _couponBloc,
        builder: (context, state) {
          if (state is DoctorCouponLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DoctorCouponLoaded) {
            final coupons = state.coupons;
            if (coupons.isEmpty) {
              return const Center(child: Text('No coupons available'));
            }
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Coupons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      final isApplied = _appliedCouponId == coupon.id;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            coupon.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isApplied ? AppColors.blue : Colors.black,
                            ),
                          ),
                          subtitle: Text('${coupon.description} (${coupon.percentage}% off)'),
                          trailing: ElevatedButton(
                            onPressed: isApplied ? null : () => _applyCoupon(coupon),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isApplied ? Colors.grey : AppColors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              isApplied ? 'Applied' : 'Apply',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          if (state is DoctorCouponError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      'speciality_id': widget.doctor.mainDataId,
      'doctor_id': widget.doctor.id,
      'date': widget.date,
      'slot_id': widget.slotId,
      'time': widget.slotTime,
      'family_member_id': widget.familyMemberId,
      'fee': widget.consultationFee,
      'consultation_fee': widget.consultationFee,
    };
    _bookingBloc.add(ProcessDoctorBooking(bookingParams: bookingParams, paymentType: paymentType));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _couponBloc),
        BlocProvider.value(value: _bookingBloc),
      ],
      child: BlocListener<DoctorCouponBloc, DoctorCouponState>(
        listener: (context, state) {
          if (state is DoctorCouponApplied) {
            setState(() {
              _discountedFee = state.applied.finalAmount;
              _appliedCouponCode = state.applied.code;
           //   _appliedCouponId = state.applied.couponId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Coupon applied! Discount: ₹${state.applied.discountAmount}')),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is DoctorCouponApplyError) {
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
        child: BlocConsumer<DoctorBookingBloc, DoctorBookingState>(
          listener: (context, state) {
            if (state is DoctorBookingSuccess) {
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
            } else if (state is DoctorBookingFailure) {
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
            final isProcessing = state is DoctorBookingLoading;
            return SafeArea(
              top: false,
              bottom: true,
              child: Scaffold(
                backgroundColor: AppColors.whiteColor,
                appBar: AppBar(
                  title: const Text(
                    'Confirm Booking',
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
                body: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Doctor card
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            widget.doctor.image,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 70),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.doctor.name,
                                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(widget.doctor.specialization, style: const TextStyle(fontSize: 12, color: Colors.black)),
                                              Text('Qual: ${widget.doctor.qualificationNames}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                                              const SizedBox(height: 4),
                                              Text('Exp: ${widget.doctor.experience} yrs', style: const TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Slot & Fee card
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
                                            const Icon(Icons.calendar_today, size: 14, color: AppColors.blue),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${widget.formattedDate} at ${widget.slotTime}',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: AppColors.blue),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Patient: ${widget.familyMemberName}',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Consultation Fee', style: TextStyle(fontSize: 14)),
                                            Text('₹${widget.consultationFee}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        if (_appliedCouponCode != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Coupon Discount ($_appliedCouponCode)',
                                                style: const TextStyle(color: Colors.green, fontSize: 12.5),
                                              ),
                                              Text(
                                                '- ₹${_originalFee - _discountedFee}',
                                                style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Total',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                '₹$_discountedFee',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          const SizedBox(height: 8),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Total',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                '₹$_discountedFee',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        OutlinedButton.icon(
                                          onPressed: _showCouponBottomSheet,
                                          icon: const Icon(Icons.local_offer, size: 18),
                                          label: const Text('Apply Coupon'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.blue,
                                            side: const BorderSide(color: AppColors.blue),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isProcessing ? null : _showPaymentOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isProcessing
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Confirm Booking',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
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