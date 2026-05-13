import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/data/models/slot_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../lab_test_booking_bloc/lab_test_booking_bloc.dart';
import '../lab_test_booking_bloc/lab_test_booking_event.dart';
import '../lab_test_booking_bloc/lab_test_booking_state.dart';


class ConfirmLabBookingPage extends StatelessWidget {
  final int labTestId;
  final String labTestAddress;
  final List<String> prescriptionPaths;
  final FamilyMember familyMember;


  const ConfirmLabBookingPage({
    super.key,
    required this.labTestId,
    required this.labTestAddress,
    required this.prescriptionPaths,
    required this.familyMember,

  });

  bool _isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  void _showPrescriptionPreview(BuildContext context, String path) {
    final bool isNetwork =
        path.startsWith('http://') || path.startsWith('https://');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [

                  const Expanded(
                    child: Text(
                      "Prescription Preview",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: _isPdf(path)

              /// PDF UI
                  ? Container(
                height: 220,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [

                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 80,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "PDF Document",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )

              /// IMAGE UI
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),

                child: isNetwork

                /// NETWORK IMAGE
                    ? Image.network(
                  path,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                )

                /// LOCAL FILE IMAGE
                    : Image.file(
                  File(path),
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageState = context.read<LanguageBloc>().state;

    final lang = languageState is LanguageChanged
        ? languageState.language.apiCode
        : 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      body: BlocProvider(
        create: (context) => sl<LabTestBookingBloc>(),

        child: BlocConsumer<LabTestBookingBloc, LabTestBookingState>(
          listener: (context, state) {
            if (state is LabTestBookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking successful! ID: ${state.bookingId}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.popUntil(
                context,
                    (route) => route.isFirst,
              );
            }

            else if (state is LabTestBookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },

          builder: (context, state) {
            return Column(
              children: [

                /// BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// LAB CENTER CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                           color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(22),

                          ),

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius:
                                      BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.science,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  const Expanded(
                                    child: Text(
                                      'Lab Test Centre',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Text(
                                labTestAddress,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// PRESCRIPTION
                        const Text(
                          'Prescription',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 130,

                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: prescriptionPaths.length,

                            itemBuilder: (context, index) {
                              final path = prescriptionPaths[index];

                              return GestureDetector(
                                onTap: () =>
                                    _showPrescriptionPreview(
                                      context,
                                      path,
                                    ),

                                child: Container(
                                  width: 110,
                                  margin: const EdgeInsets.only(
                                    right: 14,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.06),
                                        blurRadius: 10,
                                        offset:
                                        const Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [

                                      _isPdf(path)
                                          ? const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 45,
                                      )
                                          : ClipRRect(
                                        borderRadius:
                                        BorderRadius
                                            .circular(14),
                                        child: Image.network(
                                          path,
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                          const Icon(
                                            Icons.image,
                                            size: 45,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      const Text(
                                        "View",
                                        style: TextStyle(
                                          color: AppColors.blue,
                                          fontWeight:
                                          FontWeight.w600,
                                          fontFamily:
                                          'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// PATIENT DETAILS
                        const Text(
                          'Patient Details',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(22),

                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [

                              _buildPatientRow(
                                Icons.person,
                                "Patient Name",
                                familyMember.name,
                              ),

                              const SizedBox(height: 18),

                              _buildPatientRow(
                                Icons.phone,
                                "Mobile Number",
                                familyMember.mobile,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                /// CONFIRM BUTTON
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),

                  child: SafeArea(
                    top: false,

                    child: SizedBox(
                      width: double.infinity,
                      height: 56,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                        ),

                        onPressed: state is LabTestBookingLoading
                            ? null
                            : () {
                          context.read<LabTestBookingBloc>().add(
                            BookLabTest(
                              labTestId: labTestId,
                              prescriptionPaths: prescriptionPaths,
                              lang: lang,
                              familyMemberId: familyMember.id,
                            ),
                          );
                        },
                        child:
                        state is LabTestBookingLoading
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
                          'Confirm',
                          style: TextStyle(
                            color:
                            AppColors.whiteColor,
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                            fontFamily: 'Poppins',
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

  Widget _buildPatientRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [

        Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: AppColors.blue,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}