import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../diagnostic_booking_bloc/diagnostic_booking_bloc.dart';
import '../diagnostic_booking_bloc/diagnostic_booking_event.dart';
import '../diagnostic_booking_bloc/diagnostic_booking_state.dart';
import 'dart:io';


class ConfirmBookingPage extends StatelessWidget {
  final int diagnosticId;
  final String diagnosticAddress;
  final List<String> prescriptionPaths;
  final FamilyMember familyMember;

  const ConfirmBookingPage({
    super.key,
    required this.diagnosticId,
    required this.diagnosticAddress,
    required this.prescriptionPaths,
    required this.familyMember,
  });

  @override
  Widget build(BuildContext context) {
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => sl<DiagnosticBookingBloc>(),
        child: BlocConsumer<DiagnosticBookingBloc, DiagnosticBookingState>(
          listener: (context, state) {
            if (state is DiagnosticBookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking successful! ID: ${state.bookingId}'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                ),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (state is DiagnosticBookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
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
                        // Section title: Diagnostic Centre
                        const Text(
                          'Diagnostic Centre',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.lightGreen,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    diagnosticAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins',
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Section title: Prescription
                        const Text(
                          'Prescription',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: prescriptionPaths.length,
                            itemBuilder: (context, index) {
                              final path = prescriptionPaths[index];
                              final file = File(path);
                              final isPDF = path.endsWith('.pdf');
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                  image: !isPDF
                                      ? DecorationImage(
                                    image: FileImage(file),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: isPDF
                                    ? const Center(
                                  child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                                )
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Section title: Recipient Details
                        const Text(
                          'Recipient Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 18, color:Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Name: ${familyMember.name}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Poppins',
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Mobile: ${familyMember.mobile}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Poppins',
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed Confirm button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: state is DiagnosticBookingLoading
                          ? null
                          : () {
                        context.read<DiagnosticBookingBloc>().add(
                          BookDiagnosticEvent(
                            diagnosticId: diagnosticId,
                            prescriptionPaths: prescriptionPaths,
                            lang: lang,
                            familyMemberId: familyMember.id,
                          ),
                        );
                      },
                      child: state is DiagnosticBookingLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Confirm',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
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
}