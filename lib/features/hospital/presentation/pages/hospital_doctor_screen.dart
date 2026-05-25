import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:user/features/hospital/presentation/pages/widgets/hospital_diagnostic_tab.dart';
import 'package:user/features/hospital/presentation/pages/widgets/hospital_medicine_tab.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/hospital_doctor.dart';
import '../hospital_main_data_bloc/hospital_main_data_bloc.dart';
import '../hospital_main_data_bloc/hospital_main_data_event.dart';
import '../hospital_main_data_bloc/hospital_main_data_state.dart';
import 'ambulance_pages/ambulance_family_selection_screen.dart';
import 'doctor_slot_screen.dart';




class HospitalDoctorScreen extends StatefulWidget {
  final int mainDataId;
  final int addressId;
  const HospitalDoctorScreen({super.key, required this.mainDataId, required this.addressId});

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
      create: (context) => di.sl<HospitalMainDataBloc>()..add(LoadHospitalMainData(widget.mainDataId)),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Hospital Details', style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16.5,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          )),
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hospital.tagline,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 34),
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
                        // Doctors Tab (with Admit button at the bottom)
                        Column(
                          children: [
                            Expanded(
                              child: doctors.isEmpty
                                  ? const Center(child: Text('No doctors found'))
                                  : ListView.builder(
                                itemCount: doctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DoctorSlotScreen(
                                            doctor: doctor,
                                            hospitalId: widget.mainDataId,
                                            addressId: widget.addressId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildDoctorCard(doctor),
                                  );
                                },
                              ),
                            ),
                            // Admit button only on Doctors tab
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _showAmbulanceBottomSheet(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Admit', style: TextStyle(color: Colors.white, fontSize: 14)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        // Medicines Tab
                        HospitalMedicineTab(
                          hospital: hospital,
                          addressId: widget.addressId,
                        ),
                        // Diagnostics Tab
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
      color: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: square image + name & specialization
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    doctor.image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.black,
                      child:  Icon(Icons.person, size: 40, color: AppColors.whiteColor),
                    ),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: AppColors.black.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fee: ${doctor.consultationFee.toString()}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: AppColors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Qualification row
            Row(
              children: [
                Icon(Icons.school, size: 16, color: AppColors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.qualificationNames.isNotEmpty ? doctor.qualificationNames : 'Qualification not available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Experience row
            Row(
              children: [
                Icon(Icons.work, size: 16, color: AppColors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Experience: ${doctor.experience}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                    maxLines: 2,
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

  void _showAmbulanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/ambulance.svg',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Book Ambulance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Emergency ambulance service will be dispatched to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AmbulanceFamilySelectionScreen(
                        hospitalId: widget.mainDataId,
                        addressId: widget.addressId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}