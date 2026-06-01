import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user/core/di/injection.dart' as di;
import 'package:user/features/admin_support/admin_support_screen.dart';
import '../../../../../core/utils/user_manager.dart';
import '../../../../../data/models/otp_response_model.dart';
import '../../../../../domain/entities/address.dart';
import '../../../../diagnostic/presentation/pages/diagnostics_tab.dart';
import '../../../../free_lab/presentation/pages/free_lab_packages_screen.dart';
import '../../../../hospital/presentation/pages/hospitals_tab.dart';
import '../../../../labtest/presentation/pages/lab_tests_tab.dart';
import '../../../../online_doctor/presentation/pages/online_doctors_screen.dart';
import '../../../../pharmacy/presentation/pages/pharmacy_tab.dart';
import '../../../../subscription/presentation/pages/subscriptions_page.dart';
import '../../dashboard_bloc/dashboard_bloc.dart';
import '../../dashboard_bloc/dashboard_event.dart';
import '../../dashboard_bloc/dashboard_state.dart';


class HomeTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<Address?> addressNotifier;
  final Function(int) onTabSelected;

  const HomeTab({
    super.key,
    required this.searchNotifier,
    required this.addressNotifier,
    required this.onTabSelected,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  late DashboardBloc _dashboardBloc;

  String _userName = "User";
  String _greeting = "Good Morning";


  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _quickActions = [
    {"icon": Icons.video_call, "title": "Online\nDoctor", "color": const Color(0xff0057FF), "screen": "online_doctor"},
    {"icon": Icons.local_hospital, "title": "Find\nHospitals", "color": const Color(0xff2D7DFF), "screen": "hospitals"},
    {"icon": Icons.science, "title": "Book Lab\nTest", "color": const Color(0xff8A5BFF), "screen": "lab_tests"},
    {"icon": Icons.medical_services_rounded, "title": "Order\nMedicine", "color": const Color(0xff00B894), "screen": "pharmacy"},
    {"icon": Icons.biotech_rounded, "title": "Diagnostics", "color": const Color(0xffFF5A5F), "screen": "diagnostics"},
  ];

  @override
  void initState() {
    super.initState();
    _dashboardBloc = di.sl<DashboardBloc>();
    _loadDashboard();
    _loadUserName();
    _updateGreeting();
    _searchController.addListener(_onSearchChanged);
    widget.searchNotifier.addListener(_onExternalSearchChanged);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_blinkController);

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: _blinkController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadDashboard() async {
    _dashboardBloc.add(LoadDashboard("en"));
  }


  Future<void> _loadUserName() async {
    final userName = await UserManager.getUserName();
    if (userName != null && userName.isNotEmpty) {
      setState(() {
        _userName = userName;
      });
      return;
    }

    final userJson = await _storage.read(key: 'user_data');
    if (userJson != null) {
      try {
        final user = OtpResponseModel.fromJsonString(userJson);
        setState(() => _userName = user.name.isNotEmpty ? user.name : "User");
      } catch (_) {
        setState(() => _userName = "User");
      }
    } else {
      setState(() => _userName = "User");
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) _greeting = "Good Morning";
      else if (hour < 17) _greeting = "Good Afternoon";
      else _greeting = "Good Evening";
    });
  }

  void _onSearchChanged() => widget.searchNotifier.value = _searchController.text;
  void _onExternalSearchChanged() => _searchController.text = widget.searchNotifier.value;

  void _handleQuickActionTap(Map<String, dynamic> action) {
    final screen = action['screen'] as String;
    switch (screen) {
      case 'online_doctor':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineDoctorsScreen()));
        break;
      case 'hospitals':
        Navigator.push(context, MaterialPageRoute(builder: (_) => HospitalsTab(
          searchNotifier: widget.searchNotifier, addressNotifier: widget.addressNotifier,
        )));
        break;
      case 'lab_tests':
        Navigator.push(context, MaterialPageRoute(builder: (_) => LabTestsTab(
          searchNotifier: widget.searchNotifier, addressNotifier: widget.addressNotifier,
        )));
        break;
      case 'pharmacy':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PharmacyTab(
          searchNotifier: widget.searchNotifier, addressNotifier: widget.addressNotifier,
        )));
        break;
      case 'diagnostics':
        Navigator.push(context, MaterialPageRoute(builder: (_) => DiagnosticsTab(
          searchNotifier: widget.searchNotifier, addressNotifier: widget.addressNotifier,
        )));
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.searchNotifier.removeListener(_onExternalSearchChanged);
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & Health Score Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$_greeting 👋", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xff13234B))),
                              const SizedBox(height: 4),
                              Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xff1F6BFF))),
                              const SizedBox(height: 4),
                              Text("Stay informed. Stay healthy.", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),

                        AnimatedBuilder(
                          animation: _blinkController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _blinkAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SubscriptionPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 95,
                              width: 95,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.35),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  "assets/care.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Quick Actions
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _quickActions.map((action) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _quickAction(action["icon"], action["title"], action["color"], () => _handleQuickActionTap(action)),
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Top Banners
                    if (state is DashboardLoaded && state.dashboard.banners.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(height: 160, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.95),
                        items: state.dashboard.banners.map((banner) => ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(imageUrl: banner.image, fit: BoxFit.cover, width: double.infinity),
                        )).toList(),
                      ),
                    const SizedBox(height: 20),

                    // Free Lab Packages Banner
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FreeLabPackagesScreen(
                          addressNotifier: widget.addressNotifier,
                        )));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xff0057FF), Color(0xff1F6BFF)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("🩺 Free Lab Packages", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                Text("Get free lab tests", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                              child: const Text("Book Now", style: TextStyle(color: Color(0xff0057FF), fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Promotion Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdmissionSupportScreen()),

                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [const Color(0xffEFF5FF), Colors.blue.shade50]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: const Text("🛡 Prevent Today", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 12),
                            const Text("Better Health\nStronger Tomorrow", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                            const SizedBox(height: 8),
                            Text("Regular checkups help you and your family stay disease-free.", style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xff0057FF), Color(0xff1F6BFF)]),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Book Appointment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _quickAction(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}