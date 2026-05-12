import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_bloc.dart';
import '../diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_event.dart';
import '../diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_state.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';

class DiagnosticBookingFetchDetailPage extends StatelessWidget {
  final String bookingId;

  const DiagnosticBookingFetchDetailPage({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      sl<DiagnosticBookingFetchDetailBloc>()
        ..add(LoadFetchBookingDetail(bookingId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,

          title: const Text(
            'Booking Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        body: BlocBuilder<
            DiagnosticBookingFetchDetailBloc,
            DiagnosticBookingFetchDetailState>(
          builder: (context, state) {

            if (state is DiagnosticBookingFetchDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            else if (state
            is DiagnosticBookingFetchDetailLoaded) {

              final detail = state.detail;

              final bool isPdf =
              detail.prescriptionUrl
                  .toLowerCase()
                  .contains('.pdf');

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [


                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blue,
                            AppColors.blue.withOpacity(0.8),
                          ],
                        ),

                        borderRadius:
                        BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Column(
                          children: [

                            Container(
                              padding:
                              const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(16),
                              ),

                              child: Image.network(
                                detail.diagnosticsLogo,
                                height: 70,
                                width: 70,
                                fit: BoxFit.contain,

                                errorBuilder:
                                    (_, __, ___) =>
                                const Icon(
                                  Icons.local_hospital,
                                  size: 60,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              detail.diagnosticsName,

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              detail.diagnosticsAddress,

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                BorderRadius.circular(30),
                              ),

                              child: Text(
                                detail.bookingStatus,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// =========================
                    /// PATIENT DETAILS
                    /// =========================

                    _buildSectionTitle("Patient Details"),

                    const SizedBox(height: 10),

                    _buildCard(
                      child: Column(
                        children: [

                          _buildInfoTile(
                            Icons.person,
                            "Patient Name",
                            detail.patientName,
                          ),

                          _buildInfoTile(
                            Icons.phone,
                            "Mobile",
                            detail.patientMobile,
                          ),

                          _buildInfoTile(
                            Icons.email,
                            "Email",
                            detail.patientEmail,
                          ),

                          _buildInfoTile(
                            Icons.calendar_month,
                            "DOB",
                            detail.patientDob,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// =========================
                    /// PRESCRIPTION
                    /// =========================

                    _buildSectionTitle("Prescription"),

                    const SizedBox(height: 10),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(16),

                            child: isPdf
                                ? Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.red.shade50,

                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,

                                children: const [

                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 70,
                                    color: Colors.red,
                                  ),

                                  SizedBox(height: 10),

                                  Text(
                                    "PDF Prescription",
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                      fontFamily:
                                      'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : Image.network(
                              detail.prescriptionUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,

                              errorBuilder:
                                  (_, __, ___) =>
                                  Container(
                                    height: 180,
                                    color: Colors.grey.shade200,

                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton.icon(

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColors.blue,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),

                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),

                              onPressed: () {

                                if (isPdf) {

                                  _showPdfDialog(
                                    context,
                                    detail.prescriptionUrl,
                                  );

                                } else {

                                  _showImageDialog(
                                    context,
                                    detail.prescriptionUrl,
                                  );
                                }
                              },

                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                              ),

                              label: const Text(
                                "View Prescription",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// =========================
                    /// BOOKING INFO
                    /// =========================

                    _buildSectionTitle("Booking Information"),

                    const SizedBox(height: 10),

                    _buildCard(
                      child: Column(
                        children: [

                          _buildInfoTile(
                            Icons.receipt_long,
                            "Booking ID",
                            detail.bookingId.toString(),
                          ),

                          _buildInfoTile(
                            Icons.access_time,
                            "Created On",
                            detail.createdOn,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            }

            else if (state
            is DiagnosticBookingFetchDetailError) {

              return Center(
                child: Text(state.message),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  /// =========================
  /// SECTION TITLE
  /// =========================

  Widget _buildSectionTitle(String title) {

    return Text(
      title,

      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  /// =========================
  /// COMMON CARD
  /// =========================

  Widget _buildCard({required Widget child}) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  /// =========================
  /// INFO TILE
  /// =========================

  Widget _buildInfoTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),

              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: AppColors.blue,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// IMAGE DIALOG
  /// =========================

  void _showImageDialog(
      BuildContext context,
      String imageUrl,
      ) {

    showDialog(
      context: context,

      builder: (_) => Dialog(
        backgroundColor: Colors.black,

        insetPadding:
        const EdgeInsets.all(12),

        child: Stack(
          children: [

            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              right: 10,
              top: 10,

              child: CircleAvatar(
                backgroundColor: Colors.white,

                child: IconButton(
                  icon: const Icon(Icons.close),

                  onPressed: () =>
                      Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// PDF DIALOG
  /// =========================

  void _showPdfDialog(
      BuildContext context,
      String pdfUrl,
      ) {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),

        title: const Text(
          "PDF Prescription",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),

        content: const Text(
          "This prescription is in PDF format.",
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Close"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
            ),

            onPressed: () {

              /// OPEN PDF HERE
            },

            child: const Text(
              "Open PDF",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}