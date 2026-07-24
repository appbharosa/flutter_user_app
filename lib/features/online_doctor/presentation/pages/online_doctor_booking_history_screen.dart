import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:user/features/online_doctor/presentation/pages/widgets/online_prescription_screen.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/online_doctor_booking_item.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../online_doctor_booking_history_bloc/online_doctor_booking_history_bloc.dart';
import '../online_doctor_booking_history_bloc/online_doctor_booking_history_event.dart';
import '../online_doctor_booking_history_bloc/online_doctor_booking_history_state.dart';

class OnlineDoctorBookingHistoryScreen extends StatefulWidget {
  const OnlineDoctorBookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OnlineDoctorBookingHistoryScreen> createState() => _OnlineDoctorBookingHistoryScreenState();
}

class _OnlineDoctorBookingHistoryScreenState extends State<OnlineDoctorBookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OnlineDoctorBookingHistoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc = di.sl<OnlineDoctorBookingHistoryBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final language = await LanguageService.getCurrentLanguage();
    _bloc.add(FetchAllOnlineDoctorBookings(language));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
              );
            },
          ),
          title: const Text(
            'Doctor Bookings',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.blue,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),
        ),
        body: BlocConsumer<OnlineDoctorBookingHistoryBloc, OnlineDoctorBookingHistoryState>(
          listener: (context, state) {
            if (state is OnlineDoctorBookingHistoryError) {
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
            if (state is OnlineDoctorBookingHistoryInitial || state is OnlineDoctorBookingHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OnlineDoctorBookingHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(fontSize: 16)),
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
            if (state is OnlineDoctorBookingHistoryLoaded) {
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

  Widget _buildBookingListCompleted(
      List<OnlineDoctorBookingItem> bookings, {
        required String emptyMessage,
        bool isCompleted = true, // ✅ new parameter
      }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector( // ✅ Wrap with GestureDetector
          onTap: isCompleted
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OnlinePrescriptionScreen(booking: booking),
              ),
            );
          }
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isCompleted
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnlinePrescriptionScreen(booking: booking),
                    ),
                  );
                }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: booking.image,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.name,
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,  // SemiBold
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Booking ID: ${booking.bookingId}',
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,  // SemiBold
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.black),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${booking.date} | ${booking.time}',
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,  // SemiBold
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking.specialization,
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.consultType == 'online'
                                  ? Colors.blue.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: booking.consultType == 'online'
                                    ? Colors.blue.shade200
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Text(
                              booking.consultType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: booking.consultType == 'online'
                                    ? Colors.blue.shade800
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),

                        ],
                      ),
                      if (booking.fee > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Consultation Fee: ₹${booking.fee}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingList(
      List<OnlineDoctorBookingItem> bookings, {
        required String emptyMessage,
      }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () => _showBookingDetailsDialog(context, booking),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showBookingDetailsDialog(context, booking),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: booking.image,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.name,
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Booking ID: ${booking.bookingId}',
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.black),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${booking.date} | ${booking.time}',
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking.specialization,
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.consultType == 'online'
                                  ? Colors.blue.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: booking.consultType == 'online'
                                    ? Colors.blue.shade200
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Text(
                              booking.consultType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: booking.consultType == 'online'
                                    ? Colors.blue.shade800
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (booking.fee > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Consultation Fee: ₹${booking.fee}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  void dispose() {
    _tabController.dispose();
    _bloc.close();
    super.dispose();
  }

// Shows the detailed dialog for a booking
  void _showBookingDetailsDialog(BuildContext context, OnlineDoctorBookingItem booking) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(booking.image),
              onBackgroundImageError: (_, __) {},
              child: booking.image.isEmpty
                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                booking.name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Booking ID', booking.bookingId),
              _infoRow('Date', booking.date),
              _infoRow('Time', booking.time),
              _infoRow('Specialization', booking.specialization),
              _infoRow('Consult Type', booking.consultType.toUpperCase()),
              if (booking.fee > 0) _infoRow('Fee', '₹${booking.fee}'),
              // Add any other fields you have in OnlineDoctorBookingItem
              // e.g., doctor's clinic, status, etc.
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),

        ],
      ),
    );
  }

// Helper widget to display a labeled info row
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54,fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}