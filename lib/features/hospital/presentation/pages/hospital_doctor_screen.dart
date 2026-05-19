import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/hospital/presentation/pages/widgets/hospital_diagnostic_tab.dart';
import 'package:user/features/hospital/presentation/pages/widgets/hospital_medicine_tab.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/hospital_doctor.dart';
import '../hospital_main_data_bloc/hospital_main_data_bloc.dart';
import '../hospital_main_data_bloc/hospital_main_data_event.dart';
import '../hospital_main_data_bloc/hospital_main_data_state.dart';



class HospitalDoctorScreen extends StatefulWidget {
  final int mainDataId;
  final int addressId;
  const HospitalDoctorScreen({super.key, required this.mainDataId,required this.addressId});

  @override
  State<HospitalDoctorScreen> createState() => _HospitalDoctorScreenState();
}

class _HospitalDoctorScreenState extends State<HospitalDoctorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HospitalMainDataBloc>()..add(LoadHospitalMainData(widget.mainDataId)),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Hospital Details',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,  // SemiBold
            fontFamily: 'Poppins',
          ),),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<HospitalMainDataBloc, HospitalMainDataState>(
          builder: (context, state) {
            if (state is HospitalMainDataLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HospitalMainDataError) {
              return Center(child: Text(state.message));
            }
            if (state is HospitalMainDataLoaded) {
              final hospital = state.hospital;
              final doctors = state.doctors;
              return Column(
                children: [
                  // Hospital header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            hospital.logo,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, size: 60),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hospital.name,
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,  // SemiBold
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(hospital.tagline,style: TextStyle(
                                color: AppColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,  // SemiBold
                                fontFamily: 'Poppins',
                              ),),
                              const SizedBox(height: 34),
                             // Text('⏰ ${hospital.openTime} - ${hospital.closeTime}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Doctors'),
                      Tab(text: 'Medicines'),
                      Tab(text: 'Diagnostics'),
                    ],
                    indicatorColor: AppColors.blue,
                    labelColor: AppColors.blue,
                    unselectedLabelColor: Colors.grey,

                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Doctors Tab (existing)
                        doctors.isEmpty
                            ? const Center(child: Text('No doctors found'))
                            : ListView.builder(
                          itemCount: doctors.length,
                          itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
                        ),
                        // Medicines Tab
                        HospitalMedicineTab(
                          hospital: hospital,
                          addressId: widget.addressId,
                        ),
                        // Diagnostics Tab (placeholder)
                        HospitalDiagnosticTab(
                          hospital: hospital,
                          addressId: widget.addressId,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDoctorCard(HospitalDoctor doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                doctor.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,  // SemiBold
                        fontFamily: 'Poppins',
                      ),
                  ),
                  const SizedBox(height: 4),
                  Text(doctor.specialization, style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,  // SemiBold
                    fontFamily: 'Poppins',
                  ),),
                  const SizedBox(height: 4),
                  Text(doctor.qualification, style: TextStyle(
                    color: AppColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,  // SemiBold
                    fontFamily: 'Poppins',
                  ),),
                  const SizedBox(height: 4),
                  Text('Experience: ${doctor.experience}', style: TextStyle(
                    color: AppColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,  // SemiBold
                    fontFamily: 'Poppins',
                  ),),
                  const SizedBox(height: 4),
                //  Text('Fee: ₹${doctor.rating}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}