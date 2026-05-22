import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/hospital_main_data.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../medicine_booking_bloc/medicine_booking_bloc.dart';
import '../../medicine_booking_bloc/medicine_booking_event.dart';
import '../../medicine_booking_bloc/medicine_booking_state.dart';


class MedicineConfirmScreen extends StatefulWidget {
  final HospitalMainData hospital;
  final String orderType;
  final List<String> prescriptionPaths;
  final int addressId;

  const MedicineConfirmScreen({
    super.key,
    required this.hospital,
    required this.orderType,
    required this.prescriptionPaths,
    required this.addressId,
  });

  @override
  State<MedicineConfirmScreen> createState() =>
      _MedicineConfirmScreenState();
}

class _MedicineConfirmScreenState
    extends State<MedicineConfirmScreen> {
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authRepo = sl<AuthRepository>();

    final result = await authRepo.getSavedUser();

    result.fold(
          (failure) => debugPrint('User not found'),
          (user) {
        setState(() {
          _userName = user.name;
          _userPhone = user.phone;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MedicineBookingBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.black,
          title: const Text(
            'Confirm Order',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),

        body: BlocConsumer<MedicineBookingBloc,
            MedicineBookingState>(
          listener: (context, state) {
            if (state is MedicineBookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.popUntil(
                  context, (route) => route.isFirst);
            }

            if (state is MedicineBookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
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
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [


                        const SizedBox(height: 22),

                        /// DELIVERY ADDRESS
                        _buildModernCard(
                          title: "Delivery Address",
                          icon: Icons.location_on,
                          iconColor: Colors.red,
                          child: Text(
                            widget.hospital.location ?? "",
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// PATIENT DETAILS
                        _buildModernCard(
                          title: "Patient Details",
                          icon: Icons.person,
                          iconColor: Colors.teal,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName ?? "Loading...",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _userPhone ?? "",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// ORDER TYPE
                        _buildModernCard(
                          title: "Order Type",
                          icon: Icons.shopping_bag,
                          iconColor: Colors.orange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue
                                  .withOpacity(0.08),
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.orderType,
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// PRESCRIPTIONS
                        _buildModernCard(
                          title: "Prescription Files",
                          icon: Icons.description,
                          iconColor: Colors.purple,
                          child: SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection:
                              Axis.horizontal,
                              itemCount: widget
                                  .prescriptionPaths.length,
                              itemBuilder:
                                  (context, index) {
                                final path = widget
                                    .prescriptionPaths[index];

                                final isPDF = path
                                    .toLowerCase()
                                    .endsWith('.pdf');

                                return GestureDetector(
                                  onTap: () {
                                    /// OPEN PREVIEW PAGE HERE
                                  },
                                  child: Container(
                                    width: 95,
                                    margin:
                                    const EdgeInsets.only(
                                      right: 12,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          16),
                                      border: Border.all(
                                        color: Colors
                                            .grey.shade200,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors
                                              .black12,
                                          blurRadius: 4,
                                          offset:
                                          const Offset(
                                              0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          16),
                                      child: isPDF
                                          ? Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: const [
                                          Icon(
                                            Icons
                                                .picture_as_pdf,
                                            size:
                                            42,
                                            color:
                                            Colors.red,
                                          ),
                                          SizedBox(
                                              height:
                                              8),
                                          Text(
                                            "PDF",
                                            style:
                                            TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                          : Image.file(
                                        File(path),
                                        fit: BoxFit
                                            .cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM BUTTON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.blue,
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                16),
                          ),
                        ),

                        onPressed:
                        state is MedicineBookingLoading
                            ? null
                            : () {


                          context
                              .read<
                              MedicineBookingBloc>()
                              .add(
                            SubmitMedicineBooking(
                              mainDataId:
                              widget
                                  .hospital
                                  .id,
                              orderType:
                              widget
                                  .orderType,
                              addressId:
                              widget
                                  .addressId,
                              imagePaths: widget
                                  .prescriptionPaths,
                            ),
                          );
                        },

                        child:
                        state is MedicineBookingLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          "Confirm Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}