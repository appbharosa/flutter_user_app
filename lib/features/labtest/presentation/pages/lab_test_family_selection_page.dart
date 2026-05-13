// similar to SelectLabPatientPage but with extra params
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/labtest/presentation/pages/confirm_lab_booking_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_event.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_state.dart';
import 'lab_test_confirm_booking_page.dart';

class LabTestFamilySelectionPage extends StatelessWidget {
  final int labTestId;
  final String labTestAddress;
  final List<String> prescriptionPaths;
  final int slotId;
  final int packageId;
  final int personsCount;

  const LabTestFamilySelectionPage({
    super.key,
    required this.labTestId,
    required this.labTestAddress,
    required this.prescriptionPaths,
    required this.slotId,
    required this.packageId,
    required this.personsCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FamilyMembersBloc>()..add(LoadFamilyMembers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Patient'),
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
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Choose family member',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(member.name),
                            subtitle: Text('${member.relationship} · ${member.mobile}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConfirmLabBookingPage(
                                    labTestId: labTestId,
                                    labTestAddress: labTestAddress,
                                    prescriptionPaths: prescriptionPaths,
                                    familyMember: member,

                                  ),
                                ),
                              );
                            },
                          ),
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
      ),
    );
  }
}