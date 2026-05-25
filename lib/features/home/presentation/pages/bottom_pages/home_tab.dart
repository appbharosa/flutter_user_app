import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:user/domain/entities/dashboard_banner.dart';
import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/otp_response_model.dart';
import '../../../../../domain/entities/address.dart';
import '../../../../hospital/presentation/pages/hospital_doctor_screen.dart';
import '../../../../online_doctor/presentation/pages/online_doctors_screen.dart';
import '../../dashboard_bloc/dashboard_bloc.dart';
import '../../dashboard_bloc/dashboard_event.dart';
import '../../dashboard_bloc/dashboard_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';




class HomeTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<Address?> addressNotifier;

  const HomeTab({
    Key? key,
    required this.searchNotifier,
    required this.addressNotifier,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _userName = "User";
  late DashboardBloc _dashboardBloc;
  String _greeting = "Good Morning";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dashboardBloc = di.sl<DashboardBloc>();
    _loadDashboard();
    _loadUserName();
    _updateGreeting();
    _searchController.addListener(_onSearchTextChanged);
    widget.searchNotifier.addListener(_onExternalSearchChanged);
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) _greeting = "Good Morning";
      else if (hour < 17) _greeting = "Good Afternoon";
      else _greeting = "Good Evening";
    });
  }

  Future<void> _loadDashboard() async {
    const language = 'en';
    _dashboardBloc.add(LoadDashboard(language));
  }

  Future<void> _loadUserName() async {
    final userJson = await _storage.read(key: 'user_data');
    if (userJson != null) {
      try {
        final user = OtpResponseModel.fromJsonString(userJson);
        setState(() => _userName = user.name.isNotEmpty ? user.name : 'User');
      } catch (e) {
        setState(() => _userName = 'User');
      }
    } else {
      setState(() => _userName = 'User');
    }
  }

  void _onExternalSearchChanged() {
    if (mounted) {
      setState(() {
        _searchController.text = widget.searchNotifier.value;
      });
    }
  }

  void _onSearchTextChanged() {
    if (mounted) {
      widget.searchNotifier.value = _searchController.text;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.searchNotifier.removeListener(_onExternalSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & Health Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting, style: TextStyle(fontSize: 12, color: Colors.black)),
                        const SizedBox(height: 2),
                        Text(_userName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text("Health Score", style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
                          const SizedBox(height: 2),
                          const Text("82/100", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search doctors, hospitals, tests, medicines...",
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Top Banners (from dashboard API)
                if (state is DashboardLoaded && state.dashboard.banners.where((b) => b.position == 'top-section').isNotEmpty)
                  _buildTopBannerCarousel(state.dashboard.banners.where((b) => b.position == 'top-section').toList()),
                if (state is DashboardLoaded && state.dashboard.banners.isNotEmpty) const SizedBox(height: 20),

                // Categories (quick actions)
                const Text("Categories", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _buildActionCard(
                        icon: Icons.videocam,
                        label: "Online\nDoctor",
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineDoctorsScreen())),
                      ),
                      const SizedBox(width: 20),
                      _buildActionCard(
                        icon: Icons.local_hospital,
                        label: "Find\nHospitals",
                        color: Colors.red,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineDoctorsScreen())),
                      ),
                      const SizedBox(width: 20),
                      _buildActionCard(
                        icon: Icons.science,
                        label: "Book Lab\nTest",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      const SizedBox(width: 20),
                      _buildActionCard(
                        icon: Icons.medication,
                        label: "Order\nMedicine",
                        color: Colors.green,
                        onTap: () {},
                      ),
                      const SizedBox(width: 20),
                      _buildActionCard(
                        icon: Icons.verified,
                        label: "Insurance\nSupport",
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Promotion Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blue, Colors.lightBlue.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Prevent Today", style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 2),
                      const Text("Better Health\nStronger Tomorrow", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        "Regular checkups help you and your family stay disease-free.",
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text("Book Appointment →", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Lab Test Banners (if available)
                if (state is DashboardLoaded && state.dashboard.labTestBanners.isNotEmpty) ...[
                  const Text("Lab Tests", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildLabBannerCarousel(state.dashboard.labTestBanners),
                  const SizedBox(height: 20),
                ],

                // Health Snapshot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Health Snapshot", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildHealthMetric("Heart Rate", "72 bpm", "Normal", Colors.red),
                    const SizedBox(width: 10),
                    _buildHealthMetric("SpO₂", "98%", "Normal", Colors.blue),
                    const SizedBox(width: 10),
                    _buildHealthMetric("Sleep", "7h 20m", "Good", Colors.green),
                    const SizedBox(width: 10),
                    _buildHealthMetric("Steps", "4,230", "Active", Colors.orange),
                  ],
                ),
                const SizedBox(height: 20),

                // Upcoming Appointment Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, size: 24, color: AppColors.blue),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Dr. Rohan Mehta", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text("General Physician", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text("20 May 2024 • 11:00 AM", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Confirmed",
                            style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Medicine Reminder
                const Text("Medicine Reminder", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.medication, size: 24, color: Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Calcium Tablet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text("1 Tablet after Lunch", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text("Today, 1:00 PM", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade50,
                            foregroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text("Refill Now", style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBannerCarousel(List<DashboardBanner> banners) {
    return CarouselSlider(
      options: CarouselOptions(height: 150, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.9),
      items: banners.map((banner) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: banner.image,
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) => Container(color: Colors.grey.shade200),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabBannerCarousel(List<DashboardBanner> banners) {
    return CarouselSlider(
      options: CarouselOptions(height: 100, autoPlay: true, viewportFraction: 0.8),
      items: banners.map((banner) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(banner.image), fit: BoxFit.cover),
          ),
          child: Center(
            child: Text(
              banner.position, // For lab test banners, the API field is 'name', but in mapping we set position = name
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)], fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, String status, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(status, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
