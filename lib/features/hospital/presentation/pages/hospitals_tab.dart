import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/hospital.dart';
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
    _hospitalBloc = sl<HospitalBloc>();
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
      print("🏥 Loading hospitals with lat=$lat, lon=$lon, lang=$lang, specialityIds=$_appliedSpecialityIds");
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
    } else {
      print("⏳ HospitalsTab: address=${address?.address ?? 'null'}, language=${languageState is LanguageChanged ? languageState.language.name : 'not ready'}");
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
    return Column(
      children: [
        // Improved Filter Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
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
                        create: (context) => sl<HospitalFiltersBloc>(),
                        child: HospitalFiltersPage(
                          lat: lat,
                          lon: lon,
                          lang: lang,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocProvider.value(
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
                      return _buildHospitalCard(hospital);
                    },
                  );
                } else if (state is HospitalError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      color: AppColors.whiteColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                hospital.logo,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hospital.name, style: TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  )),
                  if (hospital.tagline.isNotEmpty) const SizedBox(height: 4),
                  if (hospital.tagline.isNotEmpty)
                    Text(hospital.tagline, style: TextStyle(
                      color: AppColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(height: 4),
                  if (hospital.openTime.isNotEmpty && hospital.closeTime.isNotEmpty)
                    Text('⏰ ${hospital.openTime} - ${hospital.closeTime}', style: TextStyle(
                      color: AppColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital.location.isNotEmpty ? hospital.location : 'Unknown location',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
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
}