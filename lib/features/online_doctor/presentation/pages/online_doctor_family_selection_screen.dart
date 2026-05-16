import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/entities/online_doctor_slot.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_event.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_state.dart';
import 'online_doctor_confirm_booking_screen.dart';


class OnlineDoctorFamilySelectionScreen extends StatefulWidget {
  final OnlineDoctor doctor;
  final String selectedDate;
  final String formattedDate;
  final OnlineDoctorSlot slot;

  const OnlineDoctorFamilySelectionScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.formattedDate,
    required this.slot,
  });

  @override
  State<OnlineDoctorFamilySelectionScreen> createState() => _OnlineDoctorFamilySelectionScreenState();
}

class _OnlineDoctorFamilySelectionScreenState extends State<OnlineDoctorFamilySelectionScreen> {
  FamilyMember? _selectedMember;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FamilyMembersBloc>()..add(LoadFamilyMembers()),
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
            if (state is FamilyMembersLoading) return const Center(child: CircularProgressIndicator());
            if (state is FamilyMembersError) return Center(child: Text(state.message));
            if (state is FamilyMembersLoaded && state.members.isEmpty) return const Center(child: Text('No family members found'));
            if (state is FamilyMembersLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        final isSelected = _selectedMember?.id == member.id;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: Radio(
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
                              builder: (_) => OnlineDoctorConfirmBookingScreen(
                                doctor: widget.doctor,
                                selectedDate: widget.selectedDate,
                                formattedDate: widget.formattedDate,
                                slot: widget.slot,
                                familyMember: _selectedMember!,
                              ),
                            ),
                          );
                        },
                        child: const Text('Confirm', style: TextStyle(
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