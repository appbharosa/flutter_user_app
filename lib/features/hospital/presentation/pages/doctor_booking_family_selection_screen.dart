// lib/features/doctor_booking/presentation/screens/doctor_booking_family_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../../domain/entities/hospital_doctor.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_event.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_state.dart';
import 'doctor_booking_confirm_screen.dart';

class DoctorBookingFamilySelectionScreen extends StatefulWidget {
  final HospitalDoctor doctor;
  final int hospitalId;
  final int addressId;
  final int slotId;
  final String slotTime;
  final String date;
  final String formattedDate;
  final int consultationFee;

  const DoctorBookingFamilySelectionScreen({
    Key? key,
    required this.doctor,
    required this.hospitalId,
    required this.addressId,
    required this.slotId,
    required this.slotTime,
    required this.date,
    required this.formattedDate,
    required this.consultationFee,
  }) : super(key: key);

  @override
  State<DoctorBookingFamilySelectionScreen> createState() => _DoctorBookingFamilySelectionScreenState();
}

class _DoctorBookingFamilySelectionScreenState extends State<DoctorBookingFamilySelectionScreen> {
  FamilyMember? _selectedMember;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<FamilyMembersBloc>()..add(LoadFamilyMembers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Family Member',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,  // SemiBold
            fontFamily: 'Poppins',
          ),),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<FamilyMembersBloc, FamilyMembersState>(
          builder: (context, state) {
            if (state is FamilyMembersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FamilyMembersError) {
              return Center(child: Text(state.message));
            }
            if (state is FamilyMembersLoaded && state.members.isEmpty) {
              return const Center(child: Text('No family members found'));
            }
            if (state is FamilyMembersLoaded) {
              return Column(
                children: [
                  // Optional: show doctor summary
                  // Container(
                  //   padding: const EdgeInsets.all(12),
                  //   margin: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade50,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  //       const SizedBox(height: 4),
                  //       Text('${widget.formattedDate} at ${widget.slotTime}'),
                  //       Text('Consultation Fee: ₹${widget.consultationFee}'),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: Radio<int>(
                              value: member.id,
                              groupValue: _selectedMember?.id,
                              onChanged: (_) => setState(() => _selectedMember = member),
                            ),
                            title: Text(member.name),
                            subtitle: Text('${member.relationship} · ${member.mobile}'),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                        onPressed: _selectedMember == null
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorBookingConfirmScreen(
                                doctor: widget.doctor,
                                hospitalId: widget.hospitalId,
                                addressId: widget.addressId,
                                slotId: widget.slotId,
                                slotTime: widget.slotTime,
                                date: widget.date,
                                formattedDate: widget.formattedDate,
                                consultationFee: widget.consultationFee,
                                familyMemberId: _selectedMember!.id,
                                familyMemberName: _selectedMember!.name,
                              ),
                            ),
                          );
                        },
                        child: const Text('Confirm',style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,  // SemiBold
                          fontFamily: 'Poppins',
                        ),),
                      ),
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
}