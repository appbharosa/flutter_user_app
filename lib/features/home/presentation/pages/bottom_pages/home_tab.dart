import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:user/core/di/injection.dart' as di;
import 'package:user/core/di/injection.dart';
import 'package:user/features/free_lab/presentation/pages/lab_screen.dart';
import 'package:user/features/pharmacy/presentation/pages/pharmacy_categoty_page.dart';
import '../../../../../core/di/injection.dart' show sl;
import '../../../../../core/services/language_service.dart';
import '../../../../../core/utils/user_manager.dart';
import '../../../../../data/models/otp_response_model.dart';
import '../../../../../domain/entities/address.dart';
import '../../../../../domain/repositories/subscription_repository.dart';
import '../../../../../domain/use_cases/get_free_lab_reports.dart';
import '../../../../admission/pages/admin_support_screen.dart';
import '../../../../diagnostic/presentation/pages/diagnostics_tab.dart';
import '../../../../free_lab/presentation/pages/free_lab_packages_screen.dart';
import '../../../../free_lab/presentation/pages/free_lab_reports_screen.dart';
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
  bool _isFreeLabUtilized = false;
  bool _hasActiveSubscription = false;
  bool _hasReports = false;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _quickActions = [
    {"svgPath": "assets/online-doctor.svg", "title": "Online\nDoctor","screen": "online_doctor"},
    {"svgPath": "assets/blood-test.svg", "title": "Book Lab\nTest", "screen": "med_tests"},
    {"svgPath": "assets/pharmacy.svg", "title": "Order\nMedicine","screen": "order_pharmacy"},
    {"svgPath": "assets/drugs.svg", "title": "find\nMedicine","screen": "pharmacy"},
    {"svgPath": "assets/hospital.svg", "title": "Find\nHospitals", "screen": "hospitals"},
    {"svgPath": "assets/observation.svg", "title": "Find Labs", "screen": "lab_tests"},
    {"svgPath": "assets/ct-scan.svg", "title": "Find\nDiagnostics", "screen": "diagnostics"},
  ];

  @override
  void initState() {
    super.initState();
    _dashboardBloc = di.sl<DashboardBloc>();
    _loadDashboard();
    _loadUserName();
    _updateGreeting();
    _checkFreeLabUtilized();
    _checkSubscriptionStatus();
    _checkReports();
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

  Future<void> _checkReports() async {
    try {
      final language = await LanguageService.getCurrentLanguage();
      final reports = await sl<GetFreeLabReports>()(language); // returns Either
      reports.fold(
            (failure) => setState(() => _hasReports = false),
            (reportList) => setState(() => _hasReports = reportList.isNotEmpty),
      );
    } catch (_) {
      setState(() => _hasReports = false);
    }
  }


  Future<void> _checkSubscriptionStatus() async {
    final language = await LanguageService.getCurrentLanguage();
    final repository = sl<SubscriptionRepository>();
    final result = await repository.getUserSubscription(language); // returns Either

    result.fold(
          (failure) async {
        // On error, fallback to stored flag
        final stored = await UserManager.hasActiveSubscription();
        if (mounted) setState(() => _hasActiveSubscription = stored);
      },
          (subscription) async {
        final isActive = subscription != null && !subscription.isExpired;
        await UserManager.setSubscriptionActive(isActive);
        if (mounted) setState(() => _hasActiveSubscription = isActive);
      },
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

  Future<void> _checkFreeLabUtilized() async {
    final utilized = await UserManager.isFreeLabUtilized();
    if (mounted) {
      setState(() {
        _isFreeLabUtilized = utilized;
      });
    }
  }

  void _onSearchChanged() => widget.searchNotifier.value = _searchController.text;
  void _onExternalSearchChanged() => _searchController.text = widget.searchNotifier.value;

  void _handleQuickActionTap(Map<String, dynamic> action) {
    final screen = action['screen'] as String;
    switch (screen) {
      case 'online_doctor':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OnlineDoctorsScreen(
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;

      case 'med_tests':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabTestScreen(
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;
      case 'order_pharmacy':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyCategoryPage(
              searchNotifier: widget.searchNotifier,
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;

      case 'pharmacy':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyTab(
              searchNotifier: widget.searchNotifier,
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;
      case 'hospitals':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HospitalsTab(
              searchNotifier: widget.searchNotifier,
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;
      case 'lab_tests':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabTestsTab(
              searchNotifier: widget.searchNotifier,
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;

      case 'diagnostics':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiagnosticsTab(
              searchNotifier: widget.searchNotifier,
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
        break;
    }
  }

  void _showReportsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FreeLabReportsScreen()),
    );
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
            top: false,
            bottom: true,
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
                                  "assets/care.jpeg",
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
                          children: _quickActions.map((action) {
                            final iconOrPath = action['svgPath'] ?? action['icon']; // use svgPath, fallback to icon
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _quickAction(iconOrPath, action["title"], () => _handleQuickActionTap(action)),
                            );
                          }).toList(),
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


                    GestureDetector(
                      onTap: () {
                        if (!_hasActiveSubscription) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionPage(),
                            ),
                          );
                        } else if (_hasReports) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FreeLabReportsScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FreeLabPackagesScreen(
                                addressNotifier: widget.addressNotifier,
                                packageId: 1,
                              ),
                            ),
                          );
                        }
                      },

                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(

                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xff0057FF),
                              Color(0xff3B82F6),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff0057FF)
                                  .withOpacity(0.20),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            /// LEFT CONTENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  const Text(
                                    " Free Lab Packages",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    "🏠 Home Collection\n      Available",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height:4),
                                  const Text(
                                    "📱 Instant Digital Reports",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height:4),
                                  const Text(
                                    "❤️ Early Detection, Better\n      Protection",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(40),
                                    ),

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        Text(
                                          !_hasActiveSubscription
                                              ? "Subscribe Now"
                                              : (_hasReports
                                              ? "View Reports"
                                              : "Book Now"),

                                          style: const TextStyle(
                                            color: Color(0xff0057FF),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Color(0xff0057FF),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// RIGHT IMAGE
                            Container(
                              width: 110,
                              height: 130,

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),

                                child: Image.asset(
                                  "assets/blood.jpeg",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Promotion Card
                    GestureDetector(
                      // In the promotion card's onTap:
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LabTestScreen(
                              addressNotifier: widget.addressNotifier,
                            ),
                          ),
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

  Widget _quickAction(dynamic iconOrPath, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F0), // light gray circle
            ),
            child: Center(
              child: iconOrPath is String
                  ? SvgPicture.asset(
                iconOrPath,
                width: 45,
                height: 45,
              )
                  : Icon(iconOrPath as IconData, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}