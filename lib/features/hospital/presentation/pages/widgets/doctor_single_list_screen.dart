import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/di/injection.dart' as di;

import '../../../../../core/services/language_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/hospital_doctor_booking_item.dart';
import '../../hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_bloc.dart';
import '../../hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_event.dart';
import '../../hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_state.dart';

class DoctorBookingHistorySingleListScreen extends StatefulWidget {
  const DoctorBookingHistorySingleListScreen({Key? key})
      : super(key: key);

  @override
  State<DoctorBookingHistorySingleListScreen> createState() =>
      _DoctorBookingHistorySingleListScreenState();
}

class _DoctorBookingHistorySingleListScreenState
    extends State<DoctorBookingHistorySingleListScreen> {
  late HospitalDoctorBookingHistoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<HospitalDoctorBookingHistoryBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final language = await LanguageService.getCurrentLanguage();
    _bloc.add(FetchAllDoctorBookings(language));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF7F9FC),

        /// APPBAR
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 60,
          backgroundColor: const Color(0xFF1F52A5),
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Stack(
            alignment: Alignment.center,
            children: [

              /// CENTER TITLE
              const Center(
                child: Text(
                  "Doctor Appointments",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              /// REFRESH BUTTON RIGHT SIDE
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _loadData,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

        ),

        /// BODY
        body: BlocConsumer<
            HospitalDoctorBookingHistoryBloc,
            HospitalDoctorBookingHistoryState>(
          listener: (context, state) {
            if (state is HospitalDoctorBookingHistoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is HospitalDoctorBookingHistoryLoading ||
                state is HospitalDoctorBookingHistoryInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is HospitalDoctorBookingHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Icon(
                      Icons.error_outline,
                      size: 70,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is HospitalDoctorBookingHistoryLoaded) {

              /// MERGE BOTH LISTS
              final allBookings = [
                ...state.activeBookings,
                ...state.completedBookings,
              ];

              if (allBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.medical_services_outlined,
                        size: 90,
                        color: Colors.grey.shade300,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "No doctor bookings found",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allBookings.length,
                itemBuilder: (context, index) {

                  final booking = allBookings[index];

                  final isCompleted =
                  state.completedBookings.contains(booking);

                  return _buildBookingCard(
                    booking,
                    isCompleted,
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  /// BOOKING CARD
  Widget _buildBookingCard(
      HospitalDoctorBookingItem booking,
      bool isCompleted,
      ) {

    final isOffline =
        booking.consultType.toLowerCase() == "offline";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [

          /// TOP HEADER
          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [
                  const Color(0xff1BAA5C),
                  const Color(0xff23C16B),
                ]
                    : [
                  const Color(0xFF1F52A5),
                  const Color(0xFF1F52A5),
                ],
              ),

              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),

            child: Row(
              children: [

                /// IMAGE
                Container(
                  width: 72,
                  height: 72,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),

                  child: ClipOval(
                    child: booking.image != null &&
                        booking.image!.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: booking.image!,
                      fit: BoxFit.cover,

                      placeholder: (_, __) =>
                      const Center(
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),

                      errorWidget: (_, __, ___) =>
                      const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /// DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        booking.name.isNotEmpty
                            ? booking.name
                            : "Doctor",

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        booking.specialization,

                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.16),

                              borderRadius:
                              BorderRadius.circular(30),
                            ),

                            child: Text(
                              isOffline
                                  ? "OFFLINE"
                                  : "ONLINE",

                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.16),

                              borderRadius:
                              BorderRadius.circular(30),
                            ),

                            child: Text(
                              isCompleted
                                  ? "COMPLETED"
                                  : "ACTIVE",

                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// BODY
          Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              children: [

                _infoTile(
                  Icons.confirmation_number_outlined,
                  "Booking ID",
                  booking.bookingId.toString(),
                ),

                const SizedBox(height: 14),

                _infoTile(
                  Icons.calendar_month,
                  "Appointment Date",
                  booking.date,
                ),

                const SizedBox(height: 14),

                _infoTile(
                  Icons.access_time,
                  "Appointment Time",
                  booking.time,
                ),

                const SizedBox(height: 14),

                _infoTile(
                  Icons.person_outline,
                  "Patient Name",
                  booking.patientName,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [

                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.green
                              .withOpacity(0.08),

                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: Column(
                          children: [

                            const Text(
                              "Consultation Fee",

                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "₹${booking.fee}",

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.green,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.blue
                              .withOpacity(0.08),

                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: Column(
                          children: [

                            const Text(
                              "Specialization",

                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              booking.doctorSpecialization
                                  .toString(),

                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w700,
                                color: AppColors.blue,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// INFO TILE
  Widget _infoTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Row(
      children: [

        Container(
          width: 44,
          height: 44,

          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.08),

            borderRadius:
            BorderRadius.circular(14),
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
                  color: AppColors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
}