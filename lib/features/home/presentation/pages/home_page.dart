import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/theme/app_colors.dart';
import 'package:user/features/diagnostic/presentation/pages/diagnostics_tab.dart';
import 'package:user/features/home/presentation/pages/widgets/address_bottom_sheet.dart';
import 'package:user/features/home/presentation/pages/widgets/bottom_nav_bar.dart';
import 'package:user/features/home/presentation/pages/widgets/side_drawer.dart';
import 'package:user/features/medlocker/presentation/pages/med_locker_list_page.dart';
import 'package:user/features/pedometer/gps/new_gps/gps_tracker_dialog.dart';
import 'package:user/features/pharmacy/presentation/pages/pharmacy_tab.dart';
import 'package:user/features/profile/presentation/pages/profile_page.dart';
import 'package:user/features/wallet/presentation/pages/payment_screen.dart';
import '../../../../core/di/injection.dart';
import '../../../../domain/entities/address.dart';
import '../../../contact_us/presentation/pages/contact_us_page.dart';
import '../../../hospital/presentation/pages/hospitals_tab.dart';
import '../../../labtest/presentation/pages/lab_tests_tab.dart';

import '../../../pedometer/gps/new_gps/gps_bloc.dart';

import '../address_bloc/address_bloc.dart';
import '../address_bloc/address_event.dart';
import '../address_bloc/address_state.dart';
import 'bottom_pages/cart_tab.dart';
import 'bottom_pages/home_tab.dart';
import 'bottom_pages/orders_tab.dart';
import 'bottom_pages/profile_tab.dart';
import '../../../about/presentation/pages/about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchNotifier = ValueNotifier('');

  late AddressBloc _addressBloc;
  Address? _selectedAddress;
  String _displayAddress = "Select Address";

  late GpsBloc _gpsBloc;

  final ValueNotifier<Address?> _selectedAddressNotifier = ValueNotifier(null);

  // Tabs list – not const because PharmacyTab is not constant
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
    _gpsBloc = GpsBloc();
    _addressBloc = sl<AddressBloc>()..add(LoadAddresses());
    _addressBloc.stream.listen((state) {
      if (state is AddressLoaded) {
        Address? defaultAddr;
        if (state.addresses.isNotEmpty) {
          try {
            defaultAddr = state.addresses.firstWhere((a) => a.isDefault);
          } catch (e) {
            defaultAddr = state.addresses.first;
          }
        }
        if (defaultAddr != null) {
          _selectedAddressNotifier.value = defaultAddr;
          setState(() {
            _selectedAddress = defaultAddr;
            _displayAddress = defaultAddr!.address;
          });
        }
      }
    });
  }

  void _onAddressSelected(Address address) {
    _selectedAddressNotifier.value = address;
    setState(() {
      _selectedAddress = address;
      _displayAddress = address.address;
    });
  }

  @override
  void dispose() {
    _addressBloc.close();
    _gpsBloc = GpsBloc();
    _searchController.dispose();
    _searchNotifier.dispose();
    _selectedAddressNotifier.dispose();
    super.dispose();
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
              _gpsBloc.add(StartTracking()); //  start tracking

              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: _gpsBloc, //  provide bloc to dialog
                  child: const GpsTrackerDialog(),
                ),
              );
            },
            child: const Icon(Icons.directions_walk,color: AppColors.whiteColor,),
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _tabs[_selectedIndex],
              ),
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildScrollableAddressChip() {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => _showAddressBottomSheet(),
      child: Container(
        width: screenWidth * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
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

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: Container(
        color: AppColors.blue,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search doctors, medicines, diagnostics...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _searchNotifier.value = '';
                  setState(() {});
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              _searchNotifier.value = value;
              setState(() {});
            },
            onSubmitted: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Searching for: $value')),
              );
            },
          ),
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
                  Navigator.of(context).pop();
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
                    case 5:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact Us coming soon')),
                      );
                      break;
                    case 6:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout coming soon')),
                      );
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

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddressBottomSheet(
        onAddressSelected: _onAddressSelected,
        currentAddress: _selectedAddress,
      ),
    );
  }




}