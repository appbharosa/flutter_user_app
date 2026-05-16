import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/hospital_filter_category.dart';
import '../hospital_filters_bloc/hospital_filters_bloc.dart';
import '../hospital_filters_bloc/hospital_filters_event.dart';
import '../hospital_filters_bloc/hospital_filters_state.dart';
import 'filtered_doctors_screen.dart';


class HospitalFiltersPage extends StatefulWidget {
  final double lat;
  final double lon;
  final String lang;
  const HospitalFiltersPage({
    super.key,
    required this.lat,
    required this.lon,
    required this.lang,
  });

  @override
  State<HospitalFiltersPage> createState() => _HospitalFiltersPageState();
}

class _HospitalFiltersPageState extends State<HospitalFiltersPage> {
  Set<int> _selectedSpecialityIds = {};
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<HospitalFiltersBloc>().add(LoadHospitalFilters());
  }

  void _toggleSpeciality(int id) {
    setState(() {
      if (_selectedSpecialityIds.contains(id)) {
        _selectedSpecialityIds.remove(id);
      } else {
        _selectedSpecialityIds.add(id);
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedSpecialityIds.clear();
    });
  }

  void _apply() {
    final ids = _selectedSpecialityIds.join(',');
    if (ids.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilteredDoctorsScreen(
            specialityIds: ids,
            lat: widget.lat,
            lon: widget.lon,
            lang: widget.lang,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one specialty'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Hospitals',style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,  // SemiBold
          fontFamily: 'Poppins',
        ),),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<HospitalFiltersBloc, HospitalFiltersState>(
        builder: (context, state) {
          if (state is HospitalFiltersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HospitalFiltersError) {
            return Center(child: Text(state.message));
          }
          if (state is HospitalFiltersLoaded) {
            final categories = state.categories;
            if (categories.isEmpty) {
              return const Center(child: Text('No filters available'));
            }
            // Ensure selected category is valid
            if (_selectedCategoryId == null || !categories.any((c) => c.id == _selectedCategoryId)) {
              _selectedCategoryId = categories.first.id;
            }
            // Find the selected category safely
            HospitalFilterCategory? selectedCategory;
            for (var cat in categories) {
              if (cat.id == _selectedCategoryId) {
                selectedCategory = cat;
                break;
              }
            }
            if (selectedCategory == null && categories.isNotEmpty) {
              selectedCategory = categories.first;
            }
            return Row(
              children: [
                // Left: Categories list
                Container(
                  width: 150,
                  color: Colors.grey.shade100,
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategoryId == category.id;
                      return Container(
                        color: isSelected ? Colors.blue.shade50 : null,
                        child: ListTile(
                          title: Text(category.name,style: TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,  // SemiBold
                            fontFamily: 'Poppins',
                          ),),
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Right: Specialities of selected category
                Expanded(
                  child: selectedCategory!.specialities.isEmpty
                      ? const Center(child: Text('No specialities for this category',style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,  // SemiBold
                    fontFamily: 'Poppins',
                  )))
                      : ListView.builder(
                    itemCount: selectedCategory.specialities.length,
                    itemBuilder: (context, index) {
                      final spec = selectedCategory!.specialities[index];
                      return CheckboxListTile(
                        value: _selectedSpecialityIds.contains(spec.id),
                        onChanged: (_) => _toggleSpeciality(spec.id),
                        title: Text(spec.name,style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,  // SemiBold
                          fontFamily: 'Poppins',
                        )),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                child: const Text('Apply', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}