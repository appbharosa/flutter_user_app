import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/hospital.dart';
import '../bloc/filtered_hospitals_bloc/filtered_hospitals_bloc.dart';
import '../bloc/filtered_hospitals_bloc/filtered_hospitals_state.dart';
import 'hospital_doctor_screen.dart';



class FilteredDoctorsScreen extends StatefulWidget {
  final String lang;
  final double lat;
  final double lon;
  final int catId;
  final String specialityIds;
  final int addressId;

  const FilteredDoctorsScreen({
    super.key,
    required this.lang,
    required this.lat,
    required this.lon,
    required this.catId,
    required this.specialityIds,
    required this.addressId
  });

  @override
  State<FilteredDoctorsScreen> createState() => _FilteredDoctorsScreenState();
}

class _FilteredDoctorsScreenState extends State<FilteredDoctorsScreen> {
  late FilteredHospitalsBloc _bloc;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<FilteredHospitalsBloc>();
    _bloc.add(LoadFilteredHospitals(
      lang: widget.lang,
      lat: widget.lat,
      lon: widget.lon,
      catId: widget.catId,
      specialityIds: widget.specialityIds,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Filtered Hospitals',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,  // SemiBold
            fontFamily: 'Poppins',
          ),),
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
                  hintText: 'Search by name ',
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: BlocBuilder<FilteredHospitalsBloc, FilteredHospitalsState>(
                builder: (context, state) {
                  if (state is FilteredHospitalsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FilteredHospitalsLoaded) {
                    final hospitals = state.hospitals;
                    // Filter client-side
                    final displayList = _searchQuery.isEmpty
                        ? hospitals
                        : hospitals.where((h) =>
                    h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        h.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                    if (displayList.isEmpty) {
                      return const Center(child: Text('No hospitals found'));
                    }
                    return ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final hospital = displayList[index];
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HospitalDoctorScreen(mainDataId: hospital.id,addressId: widget.addressId,),
                                ),
                              );
                            },
                            child: _buildHospitalCard(hospital));
                      },
                    );
                  } else if (state is FilteredHospitalsError) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: square image (left) + name & tagline (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    hospital.logo,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 65,
                      height: 65,
                      color: AppColors.black,
                      child: const Icon(Icons.local_hospital, size: 40, color: AppColors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hospital.tagline.isNotEmpty) const SizedBox(height: 4),
                      if (hospital.tagline.isNotEmpty)
                        Text(
                          hospital.tagline,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: AppColors.black.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Time row (below the image+text row)
            if (hospital.openTime.isNotEmpty && hospital.closeTime.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.red),
                  const SizedBox(width: 14),
                  Text(
                    '${hospital.openTime} - ${hospital.closeTime}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Address row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.red),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    hospital.location.isNotEmpty ? hospital.location : 'Unknown location',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                    maxLines: 3,
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