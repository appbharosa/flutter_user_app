// lib/features/diagnostic/presentation/screens/diagnostic_family_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/family_member.dart';
import '../../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../../../diagnostic/presentation/family_members_bloc/family_members_event.dart';
import '../../../../diagnostic/presentation/family_members_bloc/family_members_state.dart';
import 'diagnostic_confirm_screen.dart';


class HospitalDiagnosticFamilySelection extends StatefulWidget {
  final int hospitalId;
  final int addressId;
  final List<String> prescriptionPaths;

  const HospitalDiagnosticFamilySelection({
    Key? key,
    required this.hospitalId,
    required this.addressId,
    required this.prescriptionPaths,
  }) : super(key: key);

  @override
  State<HospitalDiagnosticFamilySelection> createState() => _HospitalDiagnosticFamilySelectionState();
}

class _HospitalDiagnosticFamilySelectionState extends State<HospitalDiagnosticFamilySelection> {
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
            if (state is FamilyMembersLoading) return const Center(child: CircularProgressIndicator());
            if (state is FamilyMembersError) return Center(child: Text(state.message));
            if (state is FamilyMembersLoaded && state.members.isEmpty) {
              return const Center(child: Text('No family members found'));
            }
            if (state is FamilyMembersLoaded) {
              return Column(
                children: [
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
                              builder: (_) => HospitalDiagnosticConfirm(
                                hospitalId: widget.hospitalId,
                                addressId: widget.addressId,
                                prescriptionPaths: widget.prescriptionPaths,
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