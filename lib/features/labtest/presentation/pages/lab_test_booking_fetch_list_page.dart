import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/lab_test_booking_fetch_item.dart';
import '../lab_test_booking_fetch_list_bloc/lab_test_booking_fetch_list_bloc.dart';
import '../lab_test_booking_fetch_list_bloc/lab_test_booking_fetch_list_event.dart';
import '../lab_test_booking_fetch_list_bloc/lab_test_booking_fetch_list_state.dart';
import 'lab_test_booking_fetch_detail_page.dart';


class LabTestBookingFetchListPage extends StatefulWidget {
  const LabTestBookingFetchListPage({super.key});

  @override
  State<LabTestBookingFetchListPage> createState() => _LabTestBookingFetchListPageState();
}

class _LabTestBookingFetchListPageState extends State<LabTestBookingFetchListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _ongoingScrollController = ScrollController();
  final ScrollController _completedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ongoingScrollController.addListener(() {
      if (_ongoingScrollController.position.pixels >= _ongoingScrollController.position.maxScrollExtent - 200) {
        context.read<LabTestBookingFetchListBloc>().add(LoadMoreOngoingLabTestBookings());
      }
    });
    _completedScrollController.addListener(() {
      if (_completedScrollController.position.pixels >= _completedScrollController.position.maxScrollExtent - 200) {
        context.read<LabTestBookingFetchListBloc>().add(LoadMoreCompletedLabTestBookings());
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
      create: (context) => sl<LabTestBookingFetchListBloc>()
        ..add(LoadOngoingLabTestBookings())
        ..add(LoadCompletedLabTestBookings()),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          title: const Text(
            'Lab Test Bookings',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Container(
                height: 45,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.blue,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Ongoing'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<LabTestBookingFetchListBloc, LabTestBookingFetchListState>(
          builder: (context, state) {
            if (state is LabTestBookingFetchListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LabTestBookingFetchListError) {
              return Center(child: Text(state.message));
            } else if (state is LabTestBookingFetchListLoaded) {
              return
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(context, state.ongoingList, state.hasMoreOngoing, _ongoingScrollController, isCompleted: false),
                    _buildList(context, state.completedList, state.hasMoreCompleted, _completedScrollController, isCompleted: true),
                  ],
                );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<LabTestBookingFetchItem> list, bool hasMore, ScrollController controller, {required bool isCompleted}) {
    if (list.isEmpty) {
      return const Center(child: Text('No bookings found', style: TextStyle(fontFamily: 'Poppins')));
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final item = list[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LabTestBookingFetchDetailPage(bookingId: item.bookingId)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item.logo, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.science, size: 40)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isNotEmpty ? item.name : 'Lab Test',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.red),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location.isNotEmpty ? item.location : 'Address not provided',
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            'Booking ID: ${item.bookingId}',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.blue),
                          ),
                        ),
                        if (isCompleted && item.completedDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Completed: ${item.completedDate}',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.chevron_right, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}