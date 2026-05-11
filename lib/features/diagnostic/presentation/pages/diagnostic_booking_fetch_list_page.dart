import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/diagnostic_booking_fetch_item.dart';
import '../diagnostic_bookings_bloc/diagnostic_booking_fetch_list_bloc.dart';
import '../diagnostic_bookings_bloc/diagnostic_booking_fetch_list_event.dart';
import '../diagnostic_bookings_bloc/diagnostic_booking_fetch_list_state.dart';
import 'diagnostic_booking_fetch_detail_page.dart';


class DiagnosticBookingFetchListPage extends StatefulWidget {
  const DiagnosticBookingFetchListPage({super.key});

  @override
  State<DiagnosticBookingFetchListPage> createState() => _DiagnosticBookingFetchListPageState();
}

class _DiagnosticBookingFetchListPageState extends State<DiagnosticBookingFetchListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _ongoingScrollController = ScrollController();
  final ScrollController _completedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ongoingScrollController.addListener(() {
      if (_ongoingScrollController.position.pixels >= _ongoingScrollController.position.maxScrollExtent - 200) {
        context.read<DiagnosticBookingFetchListBloc>().add(LoadMoreOngoingFetchBookings());
      }
    });
    _completedScrollController.addListener(() {
      if (_completedScrollController.position.pixels >= _completedScrollController.position.maxScrollExtent - 200) {
        context.read<DiagnosticBookingFetchListBloc>().add(LoadMoreCompletedFetchBookings());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ongoingScrollController.dispose();
    _completedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DiagnosticBookingFetchListBloc>()
        ..add(LoadOngoingFetchBookings())
        ..add(LoadCompletedFetchBookings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Diagnostic Bookings',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.blue,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<DiagnosticBookingFetchListBloc, DiagnosticBookingFetchListState>(
          builder: (context, state) {
            if (state is DiagnosticBookingFetchListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DiagnosticBookingFetchListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DiagnosticBookingFetchListBloc>().add(LoadOngoingFetchBookings());
                        context.read<DiagnosticBookingFetchListBloc>().add(LoadCompletedFetchBookings());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is DiagnosticBookingFetchListLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(context, state.ongoingList, state.hasMoreOngoing, _ongoingScrollController),
                  _buildList(context, state.completedList, state.hasMoreCompleted, _completedScrollController),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DiagnosticBookingFetchItem> list, bool hasMore, ScrollController controller) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No bookings found',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = list[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiagnosticBookingFetchDetailPage(bookingId: item.bookingId),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.logo,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 40),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isNotEmpty ? item.name : 'Diagnostic Centre',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location.isNotEmpty ? item.location : 'Address not provided',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Booking ID: ${item.bookingId}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}