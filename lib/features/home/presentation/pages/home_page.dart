import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart' as loc;
import 'package:user/features/home/presentation/pages/widgets/address_bottom_sheet.dart';
import 'package:user/features/home/presentation/pages/widgets/bottom_nav_bar.dart';
import 'package:user/features/home/presentation/pages/widgets/side_drawer.dart';
import 'package:user/features/subscription/presentation/pages/subscriptions_page.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../domain/entities/address.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../../../contact_us/presentation/pages/contact_us_page.dart';
import '../../../diagnostic/presentation/pages/diagnostic_booking_fetch_list_page.dart';
import '../../../ecard/presentation/pages/ecard_screen.dart';
import '../../../hospital/presentation/pages/hospital_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospital_doctor_booking_history_screen.dart';
import '../../../hospital/presentation/pages/hospital_pharmacy_booking_history_screen.dart';
import '../../../hospital/presentation/pages/widgets/doctor_single_list_screen.dart';
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


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final ValueNotifier<String> _searchNotifier = ValueNotifier('');
  final ValueNotifier<Address?> _selectedAddressNotifier = ValueNotifier(null);

  late AddressBloc _addressBloc;
  late NotificationBloc _notificationBloc;

  int _unreadCount = 0;
  String _displayAddress = "Select Address";
  Address? _currentLocationAddress;
  bool _isAddressLoaded = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final loc.Location _location = loc.Location();

  late final List<Widget> _tabs = [
    HomeTab(
      searchNotifier: _searchNotifier,
      addressNotifier: _selectedAddressNotifier,
      onTabSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
    const DoctorBookingHistorySingleListScreen(),
    const ECardScreen(isFromBottomNav: true),
    const MedLockerListPage(isFromBottomNav: true),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _addressBloc = di.sl<AddressBloc>()..add(LoadAddresses());
    _notificationBloc = di.sl<NotificationBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAddress();
      _loadUnreadCount();
    });
  }

  Future<void> _initializeAddress() async {
    final savedAddressJson = await _storage.read(key: 'selected_address');
    if (savedAddressJson != null && savedAddressJson.isNotEmpty) {
      final address = Address.fromJsonString(savedAddressJson);
      _selectedAddressNotifier.value = address;
      setState(() {
        _displayAddress = address.address;
        _isAddressLoaded = true;
      });
    } else {
      await _fetchCurrentLocationOnce();
    }
  }

  Future<void> _fetchCurrentLocationOnce() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _displayAddress = "Location disabled";
        });
        return;
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() {
            _displayAddress = "Location permission denied";
          });
          return;
        }
      }

      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }

      loc.LocationData locationData = await _location.getLocation();

      loc.Position position = loc.Position(
        latitude: locationData.latitude ?? 0,
        longitude: locationData.longitude ?? 0,
        timestamp: DateTime.now(),
        accuracy: locationData.accuracy ?? 0,
        altitude: locationData.altitude ?? 0,
        heading: locationData.heading ?? 0,
        speed: locationData.speed ?? 0,
        speedAccuracy: locationData.speedAccuracy ?? 0,
        altitudeAccuracy: locationData.altitude ?? 0,
        headingAccuracy: locationData.headingAccuracy ?? 0,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final List<String> addressParts = [];

        final street = [
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty)
            place.subThoroughfare,
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty)
            place.thoroughfare,
        ].where((e) => e != null && e.isNotEmpty).join(' ');

        if (street.isNotEmpty) addressParts.add(street);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        } else if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        final fullAddress = addressParts.join(', ');

        final address = Address(
          id: -1,
          address: fullAddress,
          hno: place.subThoroughfare,
          buildingNo: place.name,
          landmark: place.subLocality,
          lat: position.latitude.toString(),
          lon: position.longitude.toString(),
          addressType: 'current_location',
          pincode: place.postalCode ?? '',
          state: place.administrativeArea ?? '',
          city: place.locality ?? '',
          isDefault: false,
        );

        _currentLocationAddress = address;
        _selectedAddressNotifier.value = address;
        await _saveAddressToStorage(address);

        setState(() {
          _displayAddress = fullAddress;
          _isAddressLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      setState(() {
        _displayAddress = "Unable to get location";
      });
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
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => AddressBottomSheet(
        onAddressSelected: _onAddressSelected,
        currentAddress: _selectedAddressNotifier.value,
        onSelectCurrentLocation: () async {
          await _fetchCurrentLocationOnce();
          if (_currentLocationAddress != null) {
            _onAddressSelected(_currentLocationAddress!);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _addressBloc.close();
    _notificationBloc.close();
    _searchNotifier.dispose();
    _selectedAddressNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideHeader = _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3 || _selectedIndex == 4;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _addressBloc),
        BlocProvider.value(value: _notificationBloc),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationsLoaded) {
            setState(() {
              _unreadCount = state.unreadCount;
            });
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF5F7FB),
          appBar: hideHeader
              ? null
              : PreferredSize(
            preferredSize: const Size.fromHeight(78),
            child: _buildHeader(),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _tabs,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
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
            onTap: () {
              _showSideMenuDialog(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xff1F2A55),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: _showAddressBottomSheet,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F7FB),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xff0057FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _displayAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff13234B),
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationListScreen(),
                ),
              );
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xff1F2A55),
                  ),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 3,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
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
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
                child:
                SideMenuDialog(
                  onMenuItemSelected: (index) {
                    Navigator.pop(context);
                    switch (index) {
                      case 0: // Profile
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                        break;
                      case 1: // Med Locker
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MedLockerListPage()));
                        break;
                      case 2: // Wallet
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
                        break;
                      case 3: // Subscription
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage()));
                        break;
                      case 4: // About
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
                        break;
                      case 5: // Contact Us
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsPage()));
                        break;
                      case 6: // Diagnostic Bookings
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticBookingFetchListPage()));
                        break;
                      case 7: // Hospital Bookings -> Hospital Diagnostic Bookings
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalBookingHistoryScreen()));
                        break;
                      case 8: // Hospital Pharmacy Bookings
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalPharmacyBookingHistoryScreen()));
                        break;
                      case 9: // Hospital Doctor Bookings
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalDoctorBookingHistoryScreen()));
                        break;
                      case 10: // LabTest Bookings
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LabTestBookingFetchListPage()));
                        break;
                      case 11: // Pharmacy Bookings (regular)
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyBookingHistoryScreen()));
                        break;
                      case 12: // My eCard
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ECardScreen()));
                        break;
                      case 13: // Online Doctor Bookings
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineDoctorBookingHistoryScreen()));
                        break;
                    }
                  },
                )
              ),
            ),
          ),
        );
      },
    );
  }
}



