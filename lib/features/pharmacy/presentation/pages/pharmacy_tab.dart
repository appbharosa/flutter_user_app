import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/pharmacy/presentation/pages/pharmacy_detail_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/pharmacy.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/pharmacy_bloc.dart';
import '../bloc/pharmacy_event.dart';
import '../bloc/pharmacy_state.dart';

class PharmacyTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<Address?> addressNotifier;
  const PharmacyTab({
    super.key,
    required this.searchNotifier,
    required this.addressNotifier,
  });

  @override
  State<PharmacyTab> createState() => _PharmacyTabState();
}
class _PharmacyTabState extends State<PharmacyTab> {
  late PharmacyBloc _pharmacyBloc;
  final ScrollController _scrollController = ScrollController();
  bool _dataLoaded = false;
  String _searchQuery = '';
  List<Pharmacy> _originalPharmacies = [];
  List<Pharmacy> _filteredPharmacies = [];


  @override
  void initState() {
    super.initState();
    _pharmacyBloc = sl<PharmacyBloc>();
    _scrollController.addListener(_onScroll);
    widget.searchNotifier.addListener(_onSearchChanged);
    widget.addressNotifier.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    if (mounted) {
      _dataLoaded = false;
      _loadData();
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration.zero);
    final address = widget.addressNotifier.value;
    final languageState = context.read<LanguageBloc>().state;

    if (address != null && languageState is LanguageChanged) {
      final lat = double.tryParse(address.lat) ?? 0.0;
      final lon = double.tryParse(address.lon) ?? 0.0;
      final lang = languageState.language.apiCode;
      _pharmacyBloc.add(LoadPharmacies(page: 1, lat: lat, lon: lon, lang: lang));
      setState(() => _dataLoaded = true);
    } else if (address == null) {
      print("⚠️ PharmacyTab: No address selected yet");
    } else if (languageState is! LanguageChanged) {
      print("⚠️ PharmacyTab: Language not settled yet");
    }
  }


  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = widget.searchNotifier.value;
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPharmacies = List.from(_originalPharmacies);
    } else {
      _filteredPharmacies = _originalPharmacies.where((pharmacy) =>
      pharmacy.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pharmacy.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  void _onScroll() {
    if (_searchQuery.isEmpty) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _pharmacyBloc.add(LoadMorePharmacies());
      }
    }
  }

  @override
  void dispose() {
    widget.searchNotifier.removeListener(_onSearchChanged);
    widget.addressNotifier.removeListener(_onAddressChanged);
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _pharmacyBloc,
      child: BlocBuilder<PharmacyBloc, PharmacyState>(
        builder: (context, state) {
          if (state is PharmacyInitial || state is PharmacyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PharmacyLoaded) {
            if (_originalPharmacies.length != state.pharmacies.length) {
              _originalPharmacies = List.from(state.pharmacies);
              _applyFilter();
            }
            final displayList = _searchQuery.isEmpty ? state.pharmacies : _filteredPharmacies;
            if (displayList.isEmpty) {
              return const Center(child: Text('No pharmacies found'));
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: displayList.length + (_searchQuery.isEmpty && state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final pharmacy = displayList[index];
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PharmacyDetailPage(
                            pharmacy: pharmacy,
                            addressNotifier: widget.addressNotifier,
                          ),
                        ),
                      );
                    } ,
                    child: _buildPharmacyCard(pharmacy));
              },
            );
          } else if (state is PharmacyError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Card(
      color: AppColors.whiteColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pharmacy Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                pharmacy.logo,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.store, size: 40),
              ),
            ),

            const SizedBox(width: 12),

            // Details Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Pharmacy Name
                  Text(
                    pharmacy.name,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Time Row
                  if (pharmacy.openTime != null &&
                      pharmacy.closeTime != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          '${pharmacy.openTime} - ${pharmacy.closeTime}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  /// Location Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pharmacy.location,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// Tags Row (Delivery / Pickup + View Details)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTag(
                        icon: pharmacy.homeDelivery == 'yes'
                            ? Icons.delivery_dining
                            : Icons.storefront,
                        label: pharmacy.homeDelivery == 'yes'
                            ? 'Home Delivery'
                            : 'Pickup',
                        color: pharmacy.homeDelivery == 'yes'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      _buildViewDetailsButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'View Details',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.blue,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}