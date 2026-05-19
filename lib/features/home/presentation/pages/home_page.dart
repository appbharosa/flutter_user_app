import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:user/core/theme/app_colors.dart';
import 'package:user/features/diagnostic/presentation/pages/diagnostics_tab.dart';
import 'package:user/features/home/presentation/pages/widgets/address_bottom_sheet.dart';
import 'package:user/features/home/presentation/pages/widgets/bottom_nav_bar.dart';
import 'package:user/features/home/presentation/pages/widgets/side_drawer.dart';
import 'package:user/features/pedometer/gps/new_gps/gps_tracker_dialog.dart';
import 'package:user/features/pharmacy/presentation/pages/pharmacy_tab.dart';
import 'package:user/features/subscription/presentation/pages/subscriptions_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../domain/entities/address.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../../../contact_us/presentation/pages/contact_us_page.dart';
import '../../../diagnostic/presentation/pages/diagnostic_booking_fetch_list_page.dart';
import '../../../ecard/presentation/pages/ecard_screen.dart';
import '../../../hospital/presentation/pages/hospital_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospital_doctor_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospital_pharmacy_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospitals_tab.dart';
import '../../../labtest/presentation/pages/lab_test_booking_fetch_list_page.dart';
import '../../../labtest/presentation/pages/lab_tests_tab.dart';
import '../../../medlocker/presentation/pages/med_locker_list_page.dart';
import '../../../online_doctor/presentation/pages/online_doctor_booking_history_screen.dart';
import '../../../pedometer/gps/new_gps/gps_bloc.dart';
import '../../../pharmacy/presentation/pages/pharmacy_booking_history_screen.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../wallet/presentation/pages/payment_screen.dart';
import '../address_bloc/address_bloc.dart';
import '../address_bloc/address_event.dart';
import 'bottom_pages/home_tab.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchNotifier = ValueNotifier('');
  late AddressBloc _addressBloc;
  late GpsBloc _gpsBloc;
  bool _locationDialogHandled = false;
  bool _userDeniedLocation = false; // NEW: Track if user explicitly denied location

  final ValueNotifier<Address?> _selectedAddressNotifier = ValueNotifier(null);
  Address? _currentLocationAddress;
  String _displayAddress = "Select Address";

  late final List<Widget> _tabs = [
    const HomeTab(),
    HospitalsTab(searchNotifier: _searchNotifier, addressNotifier: _selectedAddressNotifier),
    LabTestsTab(searchNotifier: _searchNotifier, addressNotifier: _selectedAddressNotifier),
    DiagnosticsTab(searchNotifier: _searchNotifier, addressNotifier: _selectedAddressNotifier),
    PharmacyTab(searchNotifier: _searchNotifier, addressNotifier: _selectedAddressNotifier),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gpsBloc = GpsBloc();
    _addressBloc = sl<AddressBloc>()..add(LoadAddresses());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStartupLocationFlow();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _addressBloc.close();
    _gpsBloc.close();
    _searchController.dispose();
    _searchNotifier.dispose();
    _selectedAddressNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleStartupLocationFlow() async {
    if (_locationDialogHandled) return;
    _locationDialogHandled = true;

    bool granted = await checkLocationService();
    if (!granted && mounted) {
      _userDeniedLocation = true; // User explicitly denied location
      Future.delayed(
        const Duration(milliseconds: 400),
            () => _showAddressBottomSheet(),
      );
      return;
    }

    await _fetchCurrentLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_userDeniedLocation) {
      // Only fetch location if user did NOT deny it
      _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    if (_userDeniedLocation) return; // Skip if user denied location
    final location = await _getCurrentLocationAsAddress();
    if (location != null && mounted) {
      _currentLocationAddress = location;
      _selectedAddressNotifier.value = location;
      setState(() => _displayAddress = location.address);
    }
  }

  Future<bool> checkLocationService() async {
    final location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      bool requested = await location.requestService();
      if (!requested) return false;
    }

    final permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      final newPermission = await location.requestPermission();
      if (newPermission != loc.PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _onSelectCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showSnackBar('Location permission denied', isError: true);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final location = await _getCurrentLocationAsAddress();
    if (mounted) Navigator.pop(context);

    if (location != null) {
      _currentLocationAddress = location;
      _onAddressSelected(location);
      _userDeniedLocation = false; // Reset if user manually enables location
    } else {
      _showSnackBar('Unable to fetch current location', isError: true);
    }
  }

  Future<Address?> _getCurrentLocationAsAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final fullAddress = [
          place.name,
          place.street,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        return Address(
          id: -1,
          address: fullAddress,
          hno: null,
          buildingNo: null,
          landmark: null,
          lat: position.latitude.toString(),
          lon: position.longitude.toString(),
          addressType: 'current_location',
          pincode: place.postalCode ?? '',
          state: place.administrativeArea ?? '',
          city: place.locality ?? '',
          isDefault: false,
        );
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }
    return null;
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onAddressSelected(Address address) {
    _selectedAddressNotifier.value = address;
    setState(() => _displayAddress = address.address);
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddressBottomSheet(
        onAddressSelected: _onAddressSelected,
        currentAddress: _selectedAddressNotifier.value,
        onSelectCurrentLocation: _onSelectCurrentLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addressBloc,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: _buildAppBar(),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.blue,
            onPressed: () {
              _gpsBloc.add(StartTracking());
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: _gpsBloc,
                  child: const GpsTrackerDialog(),
                ),
              );
            },
            child: const Icon(Icons.directions_walk, color: AppColors.whiteColor),
          ),
          body: Column(
            children: [
              Expanded(child: _tabs[_selectedIndex]),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.blue,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showSideMenuDialog(context),
        ),
      ),
      title: _buildScrollableAddressChip(),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildScrollableAddressChip() {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: _showAddressBottomSheet,
      child: Container(
        width: screenWidth * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white. withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Text(
                  _displayAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  softWrap: false,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }


  void _showSideMenuDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SideMenuDialog(
                onMenuItemSelected: (index) {
                  Navigator.of(context).pop(); // close side menu
                  switch (index) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedLockerListPage()),
                      );
                      break;
                    case 2:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentScreen()),
                      );
                      break;
                    case 3:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutPage()),
                      );
                      break;
                    case 4:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContactUsPage()),
                      );
                      break;
                    case 5: // Normal Diagnostic Bookings
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DiagnosticBookingFetchListPage()),
                      );
                      break;
                    case 6: // LabTest Bookings
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LabTestBookingFetchListPage()),
                      );
                      break;
                    case 9: // Hospital Diagnostic Bookings (new)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HospitalBookingHistoryScreen()),
                      );
                      break;
                    case 10:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HospitalPharmacyBookingHistoryScreen()),
                      );
                      break;
                    case 11:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HospitalDoctorBookingHistoryScreen()),
                      );
                      break;
                    case 12:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PharmacyBookingHistoryScreen()),
                      );
                      break;
                    case 13:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ECardScreen()),
                      );
                      break;
                    case 14:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnlineDoctorBookingHistoryScreen()),
                      );
                      break;
                    default:
                    // Optional: handle unknown index
                      break;
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

}
