// lib/features/labtest/presentation/pages/select_patient_for_package_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/labtest/presentation/pages/lab_test_confirm_booking_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_event.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_state.dart';
import 'confirm_lab_booking_page.dart';



class SelectPatientForPackagePage extends StatelessWidget {
  final int labTestId;
  final String labTestAddress;
  final List<String> prescriptionPaths;
  final int slotId;
  final String slotTime;
  final String selectedDate;
  final String formattedDate;
  final int packageId;
  final String packageName;
  final String packageFasting;
  final String packageReportIn;
  final int personsCount;
  final double totalAmount;

  const SelectPatientForPackagePage({
    super.key,
    required this.labTestId,
    required this.labTestAddress,
    required this.prescriptionPaths,
    required this.slotId,
    required this.slotTime,
    required this.selectedDate,
    required this.formattedDate,
    required this.packageId,
    required this.packageName,
    required this.packageFasting,
    required this.packageReportIn,
    required this.personsCount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FamilyMembersBloc>()..add(LoadFamilyMembers()),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Select Patient', style: TextStyle(color: AppColors.whiteColor, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<FamilyMembersBloc, FamilyMembersState>(
          builder: (context, state) {
            if (state is FamilyMembersLoading) return const Center(child: CircularProgressIndicator());
            if (state is FamilyMembersError) return Center(child: Text(state.message));
            if (state is FamilyMembersLoaded && state.members.isEmpty) return const Center(child: Text('No family members found'));
            if (state is FamilyMembersLoaded) {
              return _FamilyList(
                members: state.members,
                onMemberSelected: (member) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabTestConfirmBookingPage(
                        labTestId: labTestId,
                        labTestAddress: labTestAddress,
                        prescriptionPaths: prescriptionPaths,
                        familyMember: member,
                        slotId: slotId,
                        slotTime: slotTime,
                        selectedDate: selectedDate,
                        formattedDate: formattedDate,
                        packageId: packageId,
                        packageName: packageName,
                        packageFasting: packageFasting,
                        packageReportIn: packageReportIn,
                        personsCount: personsCount,
                        totalAmount: totalAmount,
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _FamilyList extends StatefulWidget {
  final List<FamilyMember> members;
  final Function(FamilyMember) onMemberSelected;

  const _FamilyList({required this.members, required this.onMemberSelected});

  @override
  State<_FamilyList> createState() => _FamilyListState();
}

class _FamilyListState extends State<_FamilyList> {
  FamilyMember? _selectedMember;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Choose family member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.members.length,
            itemBuilder: (context, index) {
              final member = widget.members[index];
              final isSelected = _selectedMember?.id == member.id;
              return Card(
                color: Colors.grey.shade100,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Radio(value: member.id, groupValue: _selectedMember?.id, onChanged: (_) => setState(() => _selectedMember = member)),
                  title: Text(member.name, style: const TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                  subtitle: Text(member.mobile, style: const TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _selectedMember == null ? null : () => widget.onMemberSelected(_selectedMember!),
              child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}