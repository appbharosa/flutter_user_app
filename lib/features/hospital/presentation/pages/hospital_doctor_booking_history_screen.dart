import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:user/features/hospital/presentation/pages/widgets/prescription_screen.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/hospital_doctor_booking_item.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_bloc.dart';
import '../hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_event.dart';
import '../hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_state.dart';



class HospitalDoctorBookingHistoryScreen extends StatefulWidget {
  final bool isFromBottomNav; // Add this parameter
  const HospitalDoctorBookingHistoryScreen({
    Key? key,
    this.isFromBottomNav = false,
  }) : super(key: key);

  @override
  State<HospitalDoctorBookingHistoryScreen> createState() =>
      _HospitalDoctorBookingHistoryScreenState();
}

class _HospitalDoctorBookingHistoryScreenState
    extends State<HospitalDoctorBookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HospitalDoctorBookingHistoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xFF1F52A5),

          title: Row(
            children: [

              /// BACK BUTTON
              if (!widget.isFromBottomNav)
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                          (route) => false,
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

              if (!widget.isFromBottomNav)
                const SizedBox(width: 14),

              /// TITLE
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  widget.isFromBottomNav
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Doctor Appointments",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),

                  ],
                ),
              ),

              /// REFRESH BUTTON
              GestureDetector(
                onTap: _loadData,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          toolbarHeight: 45,

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                18,
              ),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashBorderRadius:
                  BorderRadius.circular(16),

                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1F52A5),
                        Color(0xFF1F52A5),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  labelColor: Colors.white,
                  unselectedLabelColor:
                  Colors.grey.shade700,

                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),

                  unselectedLabelStyle:
                  const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),

                  tabs: [

                    /// ACTIVE TAB
                    Tab(
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: const [

                          Icon(
                            Icons.access_time_filled,
                            size: 18,
                          ),

                          SizedBox(width: 8),

                          Text("Active"),
                        ],
                      ),
                    ),

                    /// COMPLETED TAB
                    Tab(
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: const [

                          Icon(
                            Icons.check_circle,
                            size: 18,
                          ),

                          SizedBox(width: 8),

                          Text("Completed"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocConsumer<HospitalDoctorBookingHistoryBloc,
            HospitalDoctorBookingHistoryState>(
          listener: (context, state) {
            if (state is HospitalDoctorBookingHistoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is HospitalDoctorBookingHistoryInitial ||
                state is HospitalDoctorBookingHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HospitalDoctorBookingHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is HospitalDoctorBookingHistoryLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(state.activeBookings, emptyMessage: 'No active doctor bookings'),
                  _buildBookingListCompleted(state.completedBookings, emptyMessage: 'No completed doctor bookings'),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(
      List<HospitalDoctorBookingItem> bookings, {
        required String emptyMessage,
        bool isCompleted = false,
      }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 90,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 18),
            Text(
              emptyMessage,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        final isOnline =
            booking.consultType.toLowerCase() == "offline";

        return GestureDetector(
          onTap: isCompleted
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrescriptionScreen(booking: booking),
              ),
            );
          }
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [

                /// TOP BLUE SECTION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff0057FF),
                        Color(0xff1F6BFF),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: Row(
                    children: [

                      /// DOCTOR IMAGE
                      Container(
                        width: 74,
                        height: 64,
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
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                              : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// DOCTOR DETAILS
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

                            const SizedBox(height: 4),

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

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.18),
                                borderRadius:
                                BorderRadius.circular(30),
                              ),
                              child: Text(
                                isOnline
                                    ? "ONLINE CONSULTATION"
                                    : "OFFLINE CONSULTATION",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            )
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

                      /// BOOKING ID
                      _infoTile(
                        Icons.confirmation_number_outlined,
                        "Booking ID",
                        booking.bookingId.toString(),
                      ),

                      const SizedBox(height: 14),

                      /// DATE
                      _infoTile(
                        Icons.calendar_month,
                        "Appointment Date",
                        booking.date,
                      ),

                      const SizedBox(height: 14),

                      /// TIME
                      _infoTile(
                        Icons.access_time,
                        "Appointment Time",
                        booking.time,
                      ),

                      const SizedBox(height: 14),

                      /// PATIENT NAME
                      _infoTile(
                        Icons.person_outline,
                        "Patient Name",
                        booking.patientName,
                      ),

                      const SizedBox(height: 18),

                      /// FEE + STATUS
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
                                BorderRadius.circular(
                                    16),
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
                                color: Colors.blue
                                    .withOpacity(0.08),
                                borderRadius:
                                BorderRadius.circular(
                                    16),
                              ),
                              child: Column(
                                children: [

                                  const Text(
                                    "Status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Center(
                                      child: Text(
                                        booking.doctorSpecialization.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w700,
                                          color: AppColors.blue,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),


                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildBookingListCompleted(
      List<HospitalDoctorBookingItem> bookings, {
        required String emptyMessage,
        bool isCompleted = true,
      }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 90,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 18),
            Text(
              emptyMessage,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        final isOnline =
            booking.consultType.toLowerCase() == "offline";

        return GestureDetector(
          onTap: isCompleted
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrescriptionScreen(booking: booking),
              ),
            );
          }
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [

                /// TOP BLUE SECTION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff0057FF),
                        Color(0xff1F6BFF),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: Row(
                    children: [

                      /// DOCTOR IMAGE
                      Container(
                        width: 74,
                        height: 64,
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
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                              : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// DOCTOR DETAILS
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

                            const SizedBox(height: 4),

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

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.18),
                                borderRadius:
                                BorderRadius.circular(30),
                              ),
                              child: Text(
                                isOnline
                                    ? "ONLINE CONSULTATION"
                                    : "OFFLINE CONSULTATION",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            )
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

                      /// BOOKING ID
                      _infoTile(
                        Icons.confirmation_number_outlined,
                        "Booking ID",
                        booking.bookingId.toString(),
                      ),

                      const SizedBox(height: 14),

                      /// DATE
                      _infoTile(
                        Icons.calendar_month,
                        "Appointment Date",
                        booking.date,
                      ),

                      const SizedBox(height: 14),

                      /// TIME
                      _infoTile(
                        Icons.access_time,
                        "Appointment Time",
                        booking.time,
                      ),

                      const SizedBox(height: 14),

                      /// PATIENT NAME
                      _infoTile(
                        Icons.person_outline,
                        "Patient Name",
                        booking.patientName,
                      ),

                      const SizedBox(height: 18),

                      /// FEE + STATUS
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
                                BorderRadius.circular(
                                    16),
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
                                color: Colors.blue
                                    .withOpacity(0.08),
                                borderRadius:
                                BorderRadius.circular(
                                    16),
                              ),
                              child: Column(
                                children: [

                                  const Text(
                                    "Status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    booking.doctorSpecialization.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
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

                      const SizedBox(height: 18),


                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            borderRadius: BorderRadius.circular(14),
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
        )
      ],
    );
  }
  @override
  void dispose() {
    _tabController.dispose();
    _bloc.close();
    super.dispose();
  }
}