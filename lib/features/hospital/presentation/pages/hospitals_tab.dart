import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/hospital/presentation/pages/hospital_doctor_screen.dart';
import '../../../../core/di/injection.dart' as sl;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/hospital.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/hospital_bloc.dart';
import '../bloc/hospital_event.dart';
import '../bloc/hospital_state.dart';
import '../hospital_filters_bloc/hospital_filters_bloc.dart';
import 'hospital_filters_page.dart';


class HospitalsTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<Address?> addressNotifier;
  const HospitalsTab({
    super.key,
    required this.searchNotifier,
    required this.addressNotifier,
  });

  @override
  State<HospitalsTab> createState() => _HospitalsTabState();
}

class _HospitalsTabState extends State<HospitalsTab> {
  late HospitalBloc _hospitalBloc;
  final ScrollController _scrollController = ScrollController();
  bool _dataLoaded = false;
  String _searchQuery = '';
  List<Hospital> _originalHospitals = [];
  List<Hospital> _filteredHospitals = [];
  String? _appliedSpecialityIds;

  @override
  void initState() {
    super.initState();
    _hospitalBloc = sl.sl<HospitalBloc>();
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
      if (_appliedSpecialityIds != null && _appliedSpecialityIds!.isNotEmpty) {
        _hospitalBloc.add(LoadHospitalsWithFilters(
          page: 1,
          lat: lat,
          lon: lon,
          lang: lang,
          specialityIds: _appliedSpecialityIds!,
        ));
      } else {
        _hospitalBloc.add(LoadHospitals(page: 1, lat: lat, lon: lon, lang: lang));
      }
      setState(() => _dataLoaded = true);
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
      _filteredHospitals = List.from(_originalHospitals);
    } else {
      _filteredHospitals = _originalHospitals.where((hospital) =>
      hospital.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hospital.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  void _onScroll() {
    if (_searchQuery.isEmpty) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (_appliedSpecialityIds != null && _appliedSpecialityIds!.isNotEmpty) {
          _hospitalBloc.add(LoadMoreHospitalsWithFilters(specialityIds: _appliedSpecialityIds!));
        } else {
          _hospitalBloc.add(LoadMoreHospitals());
        }
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
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
            );
          },
        ),
        title: const Text(
          'Hospitals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          // Filter Button
          GestureDetector(
            onTap: () {
              final address = widget.addressNotifier.value;
              final languageState = context.read<LanguageBloc>().state;
              if (address != null && languageState is LanguageChanged) {
                final lat = double.tryParse(address.lat) ?? 0.0;
                final lon = double.tryParse(address.lon) ?? 0.0;
                final lang = languageState.language.apiCode;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => sl.sl<HospitalFiltersBloc>(),
                      child: HospitalFiltersPage(
                        lat: lat,
                        lon: lon,
                        lang: lang,
                        addressId: address.id,
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select an address first'), backgroundColor: Colors.red),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _hospitalBloc,
        child: BlocBuilder<HospitalBloc, HospitalState>(
          builder: (context, state) {
            if (state is HospitalInitial || state is HospitalLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HospitalLoaded) {
              if (_originalHospitals.length != state.hospitals.length) {
                _originalHospitals = List.from(state.hospitals);
                _applyFilter();
              }
              final displayList = _searchQuery.isEmpty ? state.hospitals : _filteredHospitals;
              if (displayList.isEmpty) {
                return const Center(child: Text('No hospitals found'));
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
                  final hospital = displayList[index];
                  return InkWell(
                    onTap: () {
                      final address = widget.addressNotifier.value;
                      final languageState = context.read<LanguageBloc>().state;
                      if (address != null && languageState is LanguageChanged) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HospitalDoctorScreen(
                              mainDataId: hospital.id,
                              addressId: address.id,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select an address first'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: _buildHospitalCard(hospital),
                  );
                },
              );
            } else if (state is HospitalError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      color: AppColors.whiteColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade400, // OUTLINE COLOR
          width: 1.2, // OUTLINE WIDTH
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TOP SECTION
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// IMAGE WITH BACKGROUND
                Container(
                  width: 90,
                  height: 100,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffEEF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      hospital.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          size: 34,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                /// DETAILS
                Expanded(
                  child: SizedBox(
                    height: 82,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        /// HOSPITAL NAME
                        Text(
                          hospital.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: AppColors.black,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (hospital.tagline.isNotEmpty)
                          const SizedBox(height: 6),

                        /// SPECIALIZATION / TAGLINE
                        if (hospital.tagline.isNotEmpty)
                          Text(
                            hospital.tagline,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// TIME
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.red,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    hospital.openTime.isNotEmpty &&
                        hospital.closeTime.isNotEmpty
                        ? '${hospital.openTime} - ${hospital.closeTime}'
                        : 'Timings not available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// LOCATION
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    hospital.location.isNotEmpty
                        ? hospital.location
                        : 'Unknown location',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}