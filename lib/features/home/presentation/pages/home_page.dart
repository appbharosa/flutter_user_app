import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:url_launcher/url_launcher.dart';
import 'package:user/features/admission/pages/admin_support_screen.dart';
import 'package:user/features/home/presentation/pages/widgets/address_bottom_sheet.dart';
import 'package:user/features/home/presentation/pages/widgets/bottom_nav_bar.dart';
import 'package:user/features/home/presentation/pages/widgets/side_drawer.dart';
import 'package:user/features/subscription/presentation/pages/subscriptions_page.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../../../contact_us/presentation/pages/contact_us_page.dart';
import '../../../diagnostic/presentation/pages/diagnostic_booking_fetch_list_page.dart';
import '../../../ecard/presentation/pages/ecard_screen.dart';
import '../../../hospital/presentation/pages/hospital_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospital_doctor_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospital_pharmacy_booking_history_screen.dart';
import '../../../labtest/presentation/pages/lab_test_booking_fetch_list_page.dart';
import '../../../medlocker/presentation/pages/med_locker_list_page.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../notifications/presentation/pages/notification_list_screen.dart';
import '../../../online_doctor/presentation/pages/online_doctor_booking_history_screen.dart';
import '../../../pharmacy/presentation/pages/pharmacy_booking_history_screen.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../wallet/presentation/pages/payment_screen.dart';
import '../address_bloc/address_bloc.dart';
import '../address_bloc/address_event.dart';
import 'package:location/location.dart' as loc;
import 'bottom_pages/home_tab.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ValueNotifier<Address?> _selectedAddressNotifier = ValueNotifier(null);
  int _selectedIndex = 0;
  late AddressBloc _addressBloc;
  late NotificationBloc _notificationBloc;
  int _unreadCount = 0;
  String _displayAddress = "Select Address";
  bool _isAddressLoaded = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final loc.Location _location = loc.Location();

  // Flag to force location fetch after returning from settings
  bool _shouldFetchLocationOnResume = false;

  List<Widget> getTabs(ValueNotifier<String> searchNotifier) {
    return [
      HomeTab(
        searchNotifier: searchNotifier,
        addressNotifier: _selectedAddressNotifier,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
      ),
      const AdmissionSupportScreen(),
      const ECardScreen(isFromBottomNav: true),
      const MedLockerListPage(isFromBottomNav: true),
      const ProfilePage(),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _addressBloc = di.sl<AddressBloc>()..add(LoadAddresses());
    _notificationBloc = di.sl<NotificationBloc>();
    _restoreSelectedAddress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUnreadCount();
      if (_selectedAddressNotifier.value == null) {
        _checkLocationAndInitializeAddress();
      }
    });
  }

  Future<void> _restoreSelectedAddress() async {
    try {
      final storedAddress = await _storage.read(key: 'selected_address');
      if (storedAddress != null) {
        final address = Address.fromJsonString(storedAddress);
        _selectedAddressNotifier.value = address;
        setState(() => _displayAddress = address.address);
        _isAddressLoaded = true;
      }
    } catch (e) {
      debugPrint("Error restoring address: $e");
    }
  }

  Future<void> _checkLocationAndInitializeAddress() async {
    if (_selectedAddressNotifier.value != null) return;

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      if (Platform.isAndroid) {
        // Show the location accuracy dialog (with "No, thanks" and "Turn on")
        _showLocationAccuracyDialog();
        return;
      } else if (Platform.isIOS) {
        _showIOSLocationSheet();
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        _showAddressBottomSheet();
        return;
      }
    }

    await _fetchCurrentLocationOnce();
  }

  void _showLocationAccuracyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "For a better experience,\nyour device will need to use\nLocation Accuracy",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.3),
              ),
              const SizedBox(height: 24),
              const Text("The following settings should be on:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.blue, size: 28),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Device location", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                        SizedBox(height: 22),
                        Text(
                          "Location Accuracy helps apps and services provide more accurate location information.",
                          style: TextStyle(fontSize: 14.5, height: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text("You can change this anytime in location settings.", style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddressBottomSheet();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("No, thanks", style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Set flag to fetch location when app resumes
                        _shouldFetchLocationOnResume = true;
                        await _openLocationSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0057FF),
                        minimumSize: const Size(0, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Turn on", style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIOSLocationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 65, color: Colors.red),
            const SizedBox(height: 18),
            const Text("Location Disabled", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Please enable location services to fetch your current address.",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _shouldFetchLocationOnResume = true;
                  await AppSettings.openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0057FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Open Settings", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddressBottomSheet();
              },
              child: const Text("Select Address Manually"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationSettings() async {
    try {
      if (Platform.isAndroid) {
        const AndroidIntent intent = AndroidIntent(
          action: 'android.settings.LOCATION_SOURCE_SETTINGS',
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        await AppSettings.openAppSettings();
      }
    } catch (e) {
      debugPrint("SETTINGS ERROR: $e");
    }
  }

  Future<void> _fetchCurrentLocationOnce() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        setState(() => _displayAddress = "Location disabled");
        return;
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() => _displayAddress = "Location permission denied");
          return;
        }
      }

      if (permissionGranted != loc.PermissionStatus.granted) return;

      loc.LocationData locationData = await _location.getLocation();
      final placemarks = await geo.placemarkFromCoordinates(
        locationData.latitude ?? 0,
        locationData.longitude ?? 0,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [];

        final street = [
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) place.subThoroughfare,
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) place.thoroughfare,
        ].where((e) => e != null && e.isNotEmpty).join(' ');

        if (street.isNotEmpty) addressParts.add(street);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
        else if (place.name != null && place.name!.isNotEmpty) addressParts.add(place.name!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
        if (place.postalCode != null && place.postalCode!.isNotEmpty) addressParts.add(place.postalCode!);

        final fullAddress = addressParts.join(', ');

        final address = Address(
          id: -1,
          address: fullAddress,
          hno: place.subThoroughfare,
          buildingNo: place.name,
          landmark: place.subLocality,
          lat: locationData.latitude.toString(),
          lon: locationData.longitude.toString(),
          addressType: 'current_location',
          pincode: place.postalCode ?? '',
          state: place.administrativeArea ?? '',
          city: place.locality ?? '',
          isDefault: false,
        );

        _selectedAddressNotifier.value = address;
        await _saveAddressToStorage(address);
        setState(() {
          _displayAddress = fullAddress;
          _isAddressLoaded = true;
        });
        debugPrint("✅ Current location fetched and saved: $fullAddress");
      } else {
        debugPrint("⚠️ No placemarks found");
      }
    } catch (e) {
      debugPrint("❌ Location Error: $e");
      setState(() => _displayAddress = "Unable to get location");
    }
  }

  Future<void> _saveAddressToStorage(Address address) async {
    await _storage.write(key: 'selected_address', value: address.toJsonString());
  }

  Future<void> _loadUnreadCount() async {
    final language = await LanguageService.getCurrentLanguage();
    _notificationBloc.add(LoadNotifications(language));
  }

  void _onAddressSelected(Address address) {
    _selectedAddressNotifier.value = address;
    _saveAddressToStorage(address);
    setState(() {
      _displayAddress = address.address;
      _isAddressLoaded = true;
    });
    // If user manually selects an address, cancel any pending location fetch
    _shouldFetchLocationOnResume = false;
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AddressBottomSheet(
        onAddressSelected: _onAddressSelected,
        currentAddress: _selectedAddressNotifier.value,
        onSelectCurrentLocation: () async {
          Navigator.pop(context);
          // Force fetch current location, overriding any manual selection
          await _fetchCurrentLocationOnce();
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _addressBloc.close();
    _notificationBloc.close();
    _selectedAddressNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
      // If we have a pending location fetch (user tapped "Turn on"), fetch now
      if (_shouldFetchLocationOnResume) {
        _shouldFetchLocationOnResume = false;
        // Clear any existing address to ensure we fetch fresh
        if (_selectedAddressNotifier.value != null) {
          _selectedAddressNotifier.value = null;
          setState(() => _displayAddress = "Select Address");
        }
        await _fetchCurrentLocationOnce();
      } else if (_selectedAddressNotifier.value == null) {
        // No address and no pending flag, try to fetch normally
        bool serviceEnabled = await _location.serviceEnabled();
        loc.PermissionStatus permissionGranted = await _location.hasPermission();
        if (serviceEnabled && permissionGranted == loc.PermissionStatus.granted) {
          await _fetchCurrentLocationOnce();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchNotifier = context.watch<ValueNotifier<String>>();
    final hideHeader = _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3 || _selectedIndex == 4;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: searchNotifier),
        ChangeNotifierProvider.value(value: _selectedAddressNotifier),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _addressBloc),
          BlocProvider.value(value: _notificationBloc),
        ],
        child: BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationsLoaded) setState(() => _unreadCount = state.unreadCount);
          },
          child: SafeArea(
            bottom: true,
            top: false,
            child: Scaffold(
              backgroundColor: const Color(0xffF5F7FB),
              appBar: hideHeader ? null : PreferredSize(
                preferredSize: const Size.fromHeight(78),
                child: _buildHeader(),
              ),
              body: IndexedStack(
                index: _selectedIndex,
                children: getTabs(searchNotifier),
              ),
              bottomNavigationBar: BottomNavBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showContactOptions,
                backgroundColor: AppColors.whiteColor,
                child: Image.asset('assets/customer_support.jpeg', width: 45, height: 45, fit: BoxFit.contain),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          ),
        ),
      ),
    );
  }

  void _showContactOptions() {
    const String phoneNumber = '+919010492345';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.call, color: AppColors.blue),
              title: const Text('Call'),
              onTap: () async {
                Navigator.pop(context);
                final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(telUri)) await launchUrl(telUri);
                else _showSnackbar('Cannot make call');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                final whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
                if (await canLaunchUrl(whatsappUri)) await launchUrl(whatsappUri);
                else _showSnackbar('WhatsApp not installed');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Widget _buildHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 88,
      titleSpacing: 10,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _showSideMenuDialog(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.menu_rounded, color: Color(0xff1F2A55)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: _showAddressBottomSheet,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xffF5F7FB), borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xff0057FF), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(_displayAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff13234B))),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationListScreen()));
              _loadUnreadCount();
            },
            child: Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Color(0xff1F2A55)),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 3,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Center(
                        child: Text(_unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 60, left: 12),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(38), bottomRight: Radius.circular(38)),
                child: SideMenuDialog(
                  onMenuItemSelected: (index) {
                    Navigator.pop(context);
                    switch (index) {
                      case 0: Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())); break;
                      case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => const MedLockerListPage())); break;
                      case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())); break;
                      case 3: Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage())); break;
                      case 4: Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())); break;
                      case 5: Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsPage())); break;
                      case 6: Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticBookingFetchListPage())); break;
                      case 7: Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalBookingHistoryScreen())); break;
                      case 8: Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalPharmacyBookingHistoryScreen())); break;
                      case 9: Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalDoctorBookingHistoryScreen())); break;
                      case 10: Navigator.push(context, MaterialPageRoute(builder: (_) => const LabTestBookingFetchListPage())); break;
                      case 11: Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyBookingHistoryScreen())); break;
                      case 12: Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineDoctorBookingHistoryScreen())); break;
                      case 13: Navigator.push(context, MaterialPageRoute(builder: (_) => const ECardScreen())); break;
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



