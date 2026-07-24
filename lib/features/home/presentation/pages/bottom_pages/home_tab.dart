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
import '../../../../../core/appurls/app_urls.dart';
import '../../../../../core/di/injection.dart' show sl;
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/services/language_service.dart';
import '../../../../../core/utils/translations.dart';
import '../../../../../core/utils/user_manager.dart';
import '../../../../../data/models/free_lab_package_model.dart';
import '../../../../../data/models/otp_response_model.dart';
import '../../../../../domain/entities/address.dart';
import '../../../../../domain/entities/free_lab_package.dart';
import '../../../../../domain/repositories/subscription_repository.dart';
import '../../../../../domain/use_cases/get_free_lab_reports.dart';
import '../../../../diagnostic/presentation/pages/diagnostics_tab.dart';
import '../../../../free_lab/presentation/pages/free_lab_packages_screen.dart';
import '../../../../free_lab/presentation/pages/free_lab_reports_screen.dart';
import '../../../../free_lab/presentation/pages/free_labsub_package_screen.dart';
import '../../../../hospital/presentation/pages/hospitals_tab.dart';
import '../../../../labtest/presentation/pages/lab_tests_tab.dart';
import '../../../../online_doctor/presentation/pages/online_doctors_screen.dart';
import '../../../../pharmacy/presentation/pages/pharmacy_tab.dart';
import '../../../../subscription/presentation/pages/subscriptions_page.dart';
import '../../dashboard_bloc/dashboard_bloc.dart';
import '../../dashboard_bloc/dashboard_event.dart';
import '../../dashboard_bloc/dashboard_state.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
    {
      "svgPath": "assets/online-doctor.svg",
      "titleKey": "online_doctor",
      "screen": "online_doctor"
    },
    {
      "svgPath": "assets/blood-test.svg",
      "titleKey": "book_lab_test",
      "screen": "med_tests"
    },
    {
      "svgPath": "assets/drugs.svg",
      "titleKey": "order_medicine",
      "screen": "order_pharmacy"
    },
    {
      "svgPath": "assets/hospital.svg",
      "titleKey": "find_hospitals",
      "screen": "hospitals"
    },
    {
      "svgPath": "assets/observation.svg",
      "titleKey": "find_labs",
      "screen": "lab_tests"
    },
    {
      "svgPath": "assets/ct-scan.svg",
      "titleKey": "find_diagnostics",
      "screen": "diagnostics"
    },
    {
      "svgPath": "assets/pharmacy.svg",
      "titleKey": "find_pharmacy",
      "screen": "pharmacy"
    },
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
    )
      ..repeat(reverse: true);

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


  // ─── All your existing async methods ──────────────────────────────
  Future<void> _checkReports() async {
    try {
      final language = await LanguageService.getCurrentLanguage();
      final reports = await sl<GetFreeLabReports>()(language);
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
    final result = await repository.getUserSubscription(language);
    result.fold(
          (failure) async {
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
      setState(() => _userName = userName);
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
    final hour = DateTime
        .now()
        .hour;
    setState(() {
      if (hour < 12)
        _greeting = "Good Morning";
      else if (hour < 17)
        _greeting = "Good Afternoon";
      else
        _greeting = "Good Evening";
    });
  }

  Future<FreeLabPackage?> _fetchPackageForCategory(int categoryId) async {
    try {
      // ✅ Get DioClient from dependency injection
      final dioClient = sl<DioClient>();
      final response = await dioClient.dio.get(
        AppUrls.freeLabSubCategory,
        queryParameters: {
          'lang': 'en',
          'category_id': categoryId,
        },
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        if (result is List && result.isNotEmpty) {
          final paginationMap = result[0] as Map<String, dynamic>;
          final dataList = paginationMap['data'] as List? ?? [];
          if (dataList.isNotEmpty) {
            return FreeLabPackageModel.fromJson(dataList.first);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching package: $e');
      return null;
    }
  }


  Future<void> _checkFreeLabUtilized() async {
    final utilized = await UserManager.isFreeLabUtilized();
    if (mounted) setState(() => _isFreeLabUtilized = utilized);
  }

  void _onSearchChanged() =>
      widget.searchNotifier.value = _searchController.text;

  void _onExternalSearchChanged() =>
      _searchController.text = widget.searchNotifier.value;

  void _handleQuickActionTap(Map<String, dynamic> action) {
    final screen = action['screen'] as String;
    switch (screen) {
      case 'online_doctor':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnlineDoctorsScreen(
                  addressNotifier: widget.addressNotifier,
                ),
          ),
        );
        break;
      case 'med_tests':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LabTestScreen(
                  addressNotifier: widget.addressNotifier,
                ),
          ),
        );
        break;
      case 'order_pharmacy':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PharmacyCategoryPage(
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
            builder: (_) =>
                HospitalsTab(
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
            builder: (_) =>
                LabTestsTab(
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
            builder: (_) =>
                DiagnosticsTab(
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
            builder: (_) =>
                PharmacyTab(
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double itemSize = screenWidth > 600 ? 90 : 75;
    final double iconSize = itemSize * 0.55;

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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Greeting & Health Score Row ──────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$_greeting 👋", style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff13234B))),
                              const SizedBox(height: 4),
                              Text(_userName, style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff1F6BFF))),
                              const SizedBox(height: 4),
                              Text("Stay informed. Stay healthy.",
                                  style: TextStyle(fontSize: 12,
                                      color: Colors.grey.shade600)),
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

                    // ─── Quick Actions ────────────────────────────────
                    // ─── Quick Actions ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: screenWidth > 600
                          ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceEvenly,
                        children: _quickActions.map((action) {
                          final iconOrPath = action['svgPath'] ?? action['icon'];
                          return _quickAction(
                            iconOrPath,
                            action['titleKey'] as String, // ✅ pass the key
                                () => _handleQuickActionTap(action),
                            itemSize: itemSize,
                            iconSize: iconSize,
                          );
                        }).toList(),
                      )
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _quickActions.map((action) {
                            final iconOrPath = action['svgPath'] ?? action['icon'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _quickAction(
                                iconOrPath,
                                action['titleKey'] as String, // ✅ pass the key
                                    () => _handleQuickActionTap(action),
                                itemSize: itemSize,
                                iconSize: iconSize,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ─── Top Banners ──────────────────────────────────
                    if (state is DashboardLoaded &&
                        state.dashboard.banners.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 160,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.95,
                        ),
                        items: state.dashboard.banners.map((banner) =>
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: banner.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )).toList(),
                      ),
                    const SizedBox(height: 20),

                    // ─── Free Lab Packages Card ──────────────────────
                    GestureDetector(
                      onTap: () async {
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
                        }
                        else {
                          try {
                            final package = await _fetchPackageForCategory(23);
                            if (package != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FreeLabSubPackagesScreen(
                                    addressNotifier: widget.addressNotifier,
                                    package: package,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No package found for this category'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to load package: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                   }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xff0057FF), Color(0xff3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff0057FF).withOpacity(0.20),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const SizedBox(height: 4),
                                  const Text(
                                    "📱 Instant Digital Reports",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                                      borderRadius: BorderRadius.circular(40),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Promotion Card ──────────────────────────────
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LabTestScreen(
                                  addressNotifier: widget.addressNotifier,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xffEFF5FF),
                              Colors.blue.shade50
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "🛡 Prevent Today",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Better Health\nStronger Tomorrow",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Regular checkups help you and your family stay disease-free.",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff0057FF),
                                    Color(0xff1F6BFF)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Book Appointment",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, color: Colors.white,
                                      size: 16),
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

  // ─── Quick Action Widget ──────────────────────────────────────────────
  Widget _quickAction(dynamic iconOrPath,
      String titleKey, // ✅ now accepts a translation key
      VoidCallback onTap, {
        required double itemSize,
        required double iconSize,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: itemSize,
            height: itemSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F0),
            ),
            child: Center(
              child: iconOrPath is String
                  ? SvgPicture.asset(
                iconOrPath,
                width: iconSize,
                height: iconSize,
              )
                  : Icon(iconOrPath as IconData, size: iconSize * 0.7),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: itemSize + 10,
            child: Text(
              titleKey.tr(), // ✅ apply translation here
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: itemSize > 80 ? 12 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}