import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/hospital.dart';
import '../../../home/presentation/address_bloc/address_bloc.dart';
import '../../../home/presentation/address_bloc/address_state.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/hospital_bloc.dart';
import '../bloc/hospital_event.dart';
import '../bloc/hospital_state.dart';

class FilteredDoctorsScreen extends StatefulWidget {
  final String specialityIds;
  final double lat;
  final double lon;
  final String lang;
  const FilteredDoctorsScreen({
    super.key,
    required this.specialityIds,
    required this.lat,
    required this.lon,
    required this.lang,
  });

  @override
  State<FilteredDoctorsScreen> createState() => _FilteredDoctorsScreenState();
}

class _FilteredDoctorsScreenState extends State<FilteredDoctorsScreen> {
  late HospitalBloc _hospitalBloc;
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hospitalBloc = sl<HospitalBloc>();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  Future<void> _loadData() async {
    _hospitalBloc.add(LoadHospitalsWithFilters(
      page: 1,
      lat: widget.lat,
      lon: widget.lon,
      lang: widget.lang,
      specialityIds: widget.specialityIds,
    ));
  }

  void _onScroll() {
    if (_searchQuery.isEmpty) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _hospitalBloc.add(LoadMoreHospitalsWithFilters(specialityIds: widget.specialityIds));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _hospitalBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filtered Doctors'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or location...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: BlocBuilder<HospitalBloc, HospitalState>(
                builder: (context, state) {
                  if (state is HospitalInitial || state is HospitalLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HospitalLoaded) {
                    List<Hospital> displayList = state.hospitals;
                    if (_searchQuery.isNotEmpty) {
                      displayList = state.hospitals.where((hospital) =>
                      hospital.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          hospital.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                    }
                    if (displayList.isEmpty) {
                      return const Center(child: Text('No hospitals found'));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: displayList.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _buildHospitalCard(displayList[index]);
                      },
                    );
                  } else if (state is HospitalError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
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
                  Text(
                    hospital.name,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (hospital.tagline.isNotEmpty) const SizedBox(height: 4),
                  if (hospital.tagline.isNotEmpty)
                    Text(
                      hospital.tagline,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (hospital.openTime.isNotEmpty && hospital.closeTime.isNotEmpty)
                    Text(
                      '⏰ ${hospital.openTime} - ${hospital.closeTime}',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
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