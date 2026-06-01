import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_event.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_state.dart';



class FamilySelectionScreen extends StatefulWidget {
  const FamilySelectionScreen({Key? key}) : super(key: key);

  @override
  State<FamilySelectionScreen> createState() => _FamilySelectionScreenState();
}

class _FamilySelectionScreenState extends State<FamilySelectionScreen> {
  FamilyMember? _selectedMember;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<FamilyMembersBloc>()..add(LoadFamilyMembers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Family Member',style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.whiteColor,
          ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<FamilyMembersBloc, FamilyMembersState>(
          builder: (context, state) {
            if (state is FamilyMembersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FamilyMembersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FamilyMembersBloc>().add(LoadFamilyMembers());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is FamilyMembersLoaded && state.members.isEmpty) {
              return const Center(child: Text('No family members found. Please add a family member.'));
            }
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
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Radio<int>(
                              value: member.id,
                              groupValue: _selectedMember?.id,
                              onChanged: (_) => setState(() => _selectedMember = member),
                            ),
                            title: Text(
                              member.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${member.relationship} · ${member.mobile}',
                              style: const TextStyle(fontSize: 12),
                            ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _selectedMember == null
                            ? null
                            : () {
                          // Return the selected family member and close the screen
                          Navigator.pop(context, _selectedMember);
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
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