import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_manager.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/cashfree_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/free_lab_booking_bloc/free_lab_booking_bloc.dart';
import '../bloc/free_lab_booking_bloc/free_lab_booking_event.dart';
import '../bloc/free_lab_booking_bloc/free_lab_booking_state.dart';


class FreeLabBookingConfirmScreen extends StatefulWidget {
  final int packageId;
  final String packageName;
  final String packageDiscountPrice; // from API
  final ValueNotifier<Address?> addressNotifier;
  final int slotId;
  final String slotTime;
  final String date;
  final String formattedDate;
  final FamilyMember familyMember;

  const FreeLabBookingConfirmScreen({
    Key? key,
    required this.packageId,
    required this.packageName,
    required this.packageDiscountPrice,
    required this.addressNotifier,
    required this.slotId,
    required this.slotTime,
    required this.date,
    required this.formattedDate,
    required this.familyMember,
  }) : super(key: key);

  @override
  State<FreeLabBookingConfirmScreen> createState() => _FreeLabBookingConfirmScreenState();
}

class _FreeLabBookingConfirmScreenState extends State<FreeLabBookingConfirmScreen> {
  late FreeLabBookingBloc _bloc;
  bool _isProcessing = false;

  // Fixed charges for free package
  final double hygienicKitCharges = 99.00;
  final double sampleCollectionCharges = 0.00;

  // Dynamic total amount
  double get totalAmount {
    if (widget.packageId == 1) {
      // Free Lab Package: only hygienic kit charges apply
      return hygienicKitCharges;
    } else if (widget.packageId == 14) {
      // Medrayder Package: use discount price from API
      final price = double.tryParse(widget.packageDiscountPrice) ?? 0.0;
      return price;
    }
    // Fallback
    return double.tryParse(widget.packageDiscountPrice) ?? 0.0;
  }

  // Store order details
  String? _createdOrderId;
  String? _createdPaymentSessionId;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<FreeLabBookingBloc>();
  }

  Future<void> _processBooking() async {
    setState(() => _isProcessing = true);
    _bloc.add(CreateFreeLabOrder(
      amount: totalAmount.toInt(),
      currency: 'INR',
    ));
  }

  Future<void> _processOnlinePayment() async {
    if (_createdOrderId == null || _createdPaymentSessionId == null) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order creation failed. Please try again.'), backgroundColor: Colors.red),
      );
      return;
    }

    final cashfreeService = di.sl<CashfreeService>();

    cashfreeService.startPayment(
      orderId: _createdOrderId!,
      paymentSessionId: _createdPaymentSessionId!,
      environment: CFEnvironment.PRODUCTION,
      onSuccess: (orderId) {
        debugPrint("✅ Payment success for order: $orderId");
        _confirmBooking();
      },
      onFailure: (error) {
        debugPrint("❌ Payment failed: $error");
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $error'), backgroundColor: Colors.red),
        );
      },
    );
  }

  Future<void> _confirmBooking() async {
    final language = await LanguageService.getCurrentLanguage();
    final address = widget.addressNotifier.value;

    final bookingData = {
      'package_id': widget.packageId,
      'family_member_id': widget.familyMember.id,
      'order_id': _createdOrderId,
      'date': widget.date,
      'time': widget.slotTime,
      'price': totalAmount.toStringAsFixed(2),
      'hygienic_kit_charges': hygienicKitCharges.toStringAsFixed(2),
      'sample_collection_charges': sampleCollectionCharges.toStringAsFixed(2),
      'total_amount': totalAmount.toStringAsFixed(2),
    };

    debugPrint("📦 Submitting booking with data: $bookingData");
    _bloc.add(SubmitFreeLabBooking(
      bookingData: bookingData,
      language: language,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<FreeLabBookingBloc, FreeLabBookingState>(
        listener: (context, state) {
          if (state is FreeLabOrderCreated) {
            debugPrint("🔵 Order created - Order ID: ${state.orderId}");
            _createdOrderId = state.orderId;
            _createdPaymentSessionId = state.paymentSessionId;
            _processOnlinePayment();
          } else if (state is FreeLabBookingSuccess) {
            setState(() => _isProcessing = false);

            if (widget.packageId == 1) {
              UserManager.setFreeLabUtilized(true);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking successful!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
            );
          } else if (state is FreeLabBookingFailure) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            title: const Text(
              'Confirm Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.whiteColor,
              ),
            ),
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Summary Card (dynamic)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price Summary',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (widget.packageId == 1) ...[
                            _buildPriceRow('Hygienic Kit Charges', '₹${hygienicKitCharges.toStringAsFixed(2)}'),
                            _buildPriceRow('Sample Collection Charges', '₹${sampleCollectionCharges.toStringAsFixed(2)}'),
                            const Divider(height: 24),
                            _buildPriceRow('Total Amount', '₹${totalAmount.toStringAsFixed(2)}', isTotal: true),
                          ] else if (widget.packageId == 14) ...[
                            _buildPriceRow('Package Price', '₹${widget.packageDiscountPrice}'),
                            const Divider(height: 24),
                            _buildPriceRow('Total Amount', '₹${totalAmount.toStringAsFixed(2)}', isTotal: true),
                          ] else ...[
                            _buildPriceRow('Total Amount', '₹${totalAmount.toStringAsFixed(2)}', isTotal: true),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lab Package Section
                    const Text(
                      'Lab Package',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.packageName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address Section
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: AppColors.blue),
                        const SizedBox(width: 8),
                        const Text('Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.addressNotifier.value?.address ?? 'No address selected',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Appointment Details Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.blue),
                            const SizedBox(width: 8),
                            const Text('Appointment Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text(widget.formattedDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.blue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppColors.blue),
                            const SizedBox(width: 8),
                            const Text('Time Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text(widget.slotTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.blue)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Patient Details Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: AppColors.blue),
                              const SizedBox(width: 8),
                              const Text('Patient Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Name', widget.familyMember.name),
                          _buildDetailRow('Relationship', widget.familyMember.relationship),
                          _buildDetailRow('Mobile', widget.familyMember.mobile),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(
                          'Pay ₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? AppColors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}