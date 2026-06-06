import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/online_doctor/presentation/pages/online_doctor_detail_screen.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/online_doctor_bloc.dart';
import '../bloc/online_doctor_event.dart';
import '../bloc/online_doctor_state.dart';
import '../online_doctor_speciality_bloc/online_doctor_speciality_bloc.dart';
import '../online_doctor_speciality_bloc/online_doctor_speciality_event.dart';
import '../online_doctor_speciality_bloc/online_doctor_speciality_state.dart';

class OnlineDoctorsScreen extends StatefulWidget {
  final ValueNotifier<Address?> addressNotifier;
  const OnlineDoctorsScreen({super.key,required this.addressNotifier,});


  @override
  State<OnlineDoctorsScreen> createState() => _OnlineDoctorsScreenState();
}

class _OnlineDoctorsScreenState extends State<OnlineDoctorsScreen> {
  late OnlineDoctorBloc _doctorBloc;
  final ScrollController _scrollController = ScrollController();
  int? _selectedSpecialityId;

  @override
  void initState() {
    super.initState();
    _doctorBloc = sl<OnlineDoctorBloc>();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  double _getAverageRating(OnlineDoctor doctor) {
    if (doctor.totalReviews == 0) return 0.0;
    return doctor.totalRating / doctor.totalReviews;
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
    }
    int emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
    }
    return Row(children: stars);
  }

  Future<void> _loadData() async {
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';
    _doctorBloc.add(LoadOnlineDoctors(page: 1, lang: lang, specialityId: _selectedSpecialityId));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      debugPrint('➡️ Dispatching LoadMoreOnlineDoctors');
      _doctorBloc.add(LoadMoreOnlineDoctors());
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to calculate star rating
  double _calculateRating(OnlineDoctor doctor) {
    final totalRating = double.tryParse(doctor.totalRating.toString()) ?? 0.0;
    final totalReviews = doctor.totalReviews;
    if (totalReviews == 0) return 0.0;
    return totalRating / totalReviews;
  }



  @override
  Widget build(BuildContext context) {
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<OnlineDoctorSpecialityBloc>()..add(LoadOnlineDoctorSpecialities(lang)),
        ),
        BlocProvider.value(value: _doctorBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Online Doctors', style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          )),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Speciality dropdown – fixed long text issue
            Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<OnlineDoctorSpecialityBloc, OnlineDoctorSpecialityState>(
                builder: (context, state) {
                  if (state is OnlineDoctorSpecialityLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OnlineDoctorSpecialityError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is OnlineDoctorSpecialityLoaded) {
                    final specialities = state.specialities;
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 50),
                      child: DropdownButtonFormField<int?>(
                        isExpanded: true, // allows dropdown to expand horizontally
                        decoration: InputDecoration(
                          labelText: 'Select Speciality',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: _selectedSpecialityId,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Specialities', overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12),)),
                          ...specialities.map((spec) => DropdownMenuItem(
                            value: spec.id,
                            child: Text(
                              spec.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecialityId = value;
                          });
                          _doctorBloc.add(ChangeSpeciality(value));
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<OnlineDoctorBloc, OnlineDoctorState>(
                builder: (context, state) {
                  if (state is OnlineDoctorLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OnlineDoctorLoaded) {
                    if (state.doctors.isEmpty) {
                      return const Center(child: Text('No doctors found'));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.doctors.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.doctors.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final doctor = state.doctors[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder:(context) => OnlineDoctorDetailScreen(doctor: doctor) ));
                          },
                          child: _buildDoctorCard(doctor),
                        );
                      },
                    );
                  }
                  if (state is OnlineDoctorError) {
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

  Widget _buildDoctorCard(OnlineDoctor doctor) {
    final rating = _calculateRating(doctor);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    doctor.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (doctor.qualification.isNotEmpty)
                        Text(
                          doctor.qualification,
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(_getAverageRating(doctor)),
                          const SizedBox(width: 4),
                          Text('(${doctor.totalReviews})', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),

                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (doctor.availability == 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Available Today',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>OnlineDoctorDetailScreen(doctor: doctor)));
                },
                child: const Text(
                  'Consult Now',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.whiteColor,
                  ),                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}