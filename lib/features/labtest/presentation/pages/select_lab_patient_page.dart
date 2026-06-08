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

class SelectLabPatientPage extends StatefulWidget {
  final int labTestId;
  final String labTestAddress;
  final List<String> prescriptionPaths;
  const SelectLabPatientPage({super.key, required this.labTestId, required this.labTestAddress, required this.prescriptionPaths});

  @override
  State<SelectLabPatientPage> createState() => _SelectLabPatientPageState();
}

class _SelectLabPatientPageState extends State<SelectLabPatientPage> {
  FamilyMember? selectedMember;

  @override
  void initState() {
    super.initState();
    context.read<FamilyMembersBloc>().add(LoadFamilyMembers());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(title: const Text('Select Patient',style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,  // SemiBold
          fontFamily: 'Poppins',
        ),), backgroundColor: AppColors.blue, foregroundColor: Colors.white),
        body: BlocBuilder<FamilyMembersBloc, FamilyMembersState>(
          builder: (context, state) {
            if (state is FamilyMembersLoading) return const Center(child: CircularProgressIndicator());
            if (state is FamilyMembersError) return Center(child: Text(state.message));
            if (state is FamilyMembersLoaded && state.members.isEmpty) return const Center(child: Text('No family members found'));
            if (state is FamilyMembersLoaded) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Choose family member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        final isSelected = selectedMember?.id == member.id;
                        return Card(
                          color: Colors.grey.shade100,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: Radio(
                              value: member.id,
                              groupValue: selectedMember?.id,
                              onChanged: (_) => setState(() => selectedMember = member),
                            ),
                            title: Text(member.name,style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,  // SemiBold
                              fontFamily: 'Poppins',
                            ),),
                            subtitle: Text(' ${member.mobile}',style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,  // SemiBold
                              fontFamily: 'Poppins',
                            ),),
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
                        onPressed: selectedMember == null ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmLabBookingPage(
                                labTestId: widget.labTestId,
                                labTestAddress: widget.labTestAddress,
                                prescriptionPaths: widget.prescriptionPaths,
                                familyMember: selectedMember!,
                              ),
                            ),
                          );
                        },
                        child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16)),
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