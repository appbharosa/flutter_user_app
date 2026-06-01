import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user/core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/utils/user_manager.dart';
import '../../../../data/models/otp_response_model.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'add_family_member_screen.dart';





class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _dobController;
  late String _selectedGender;
  late String _selectedBloodGroup;
  late String _selectedCoverage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _dobController = TextEditingController();
    _selectedGender = 'Male';
    _selectedBloodGroup = 'A+';
    _selectedCoverage = 'Health Insurance';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _updateControllers(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _mobileController.text = profile.mobile;
    _dobController.text = profile.dob;
    _selectedGender = profile.gender;
    _selectedBloodGroup = profile.bloodGroup;
    _selectedCoverage = profile.coverageCategory;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.tryParse(_dobController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  void _saveChanges() {
    final updatedData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'mobile': _mobileController.text,
      'dob': _dobController.text,
      'coverage_category': Helpers.getCoverageCode(_selectedCoverage),
      'gender': Helpers.getGenderCode(_selectedGender),
      'blood_group': Helpers.getBloodGroupCode(_selectedBloodGroup),
    };
    context.read<ProfileBloc>().add(UpdateProfileEvent(updatedData));
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ProfileBloc>()..add(FetchProfile()),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.whiteColor,
          elevation: 0,
          title: Text(
            'Profile',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () async {
                final userId = await _getUserId();
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddFamilyMemberScreen(userId: userId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User not found. Please login again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              tooltip: 'Add Family Member',
            ),
            // IconButton(
            //   icon: Icon(_isEditing ? Icons.close : Icons.edit),
            //   onPressed: () => setState(() => _isEditing = !_isEditing),
            // ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
            if (state is ProfileLoaded && !_isEditing) {
              _updateControllers(state.userProfile);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoaded) {
              final profile = state.userProfile;
              if (_nameController.text.isEmpty) _updateControllers(profile);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profile.image),
                      onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 60),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('Name', _nameController, _isEditing),
                    _buildInfoRow('Email', _emailController, _isEditing),
                    _buildInfoRow('Mobile', _mobileController, _isEditing),
                    _buildDateRow(_isEditing),
                    _buildDropdownRow('Gender', _selectedGender, _isEditing,
                        ['Male', 'Female'], (value) {
                          setState(() => _selectedGender = value!);
                        }),
                    _buildDropdownRow('Blood Group', _selectedBloodGroup, _isEditing,
                        ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'], (value) {
                          setState(() => _selectedBloodGroup = value!);
                        }),
                    _buildDropdownRow('Coverage Category', _selectedCoverage, _isEditing, [
                      'Health Insurance',
                      'ESIC/EHS/CGHS',
                      'Aarogya Sree',
                      'Cash',
                      'Other',
                      'Aarogya Sree and Health Insurance'
                    ], (value) {
                      setState(() => _selectedCoverage = value!);
                    }),
                    const SizedBox(height: 30),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                          onPressed: _saveChanges,
                          child: const Text(
                            "Update",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No profile data'));
          },
        ),
      ),
    );
  }

  Future<int?> _getUserId() async {
    const storage = FlutterSecureStorage();
    final userJson = await storage.read(key: 'user_data');
    if (userJson != null) {
      try {
        final user = OtpResponseModel.fromJsonString(userJson);
        return user.id;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Widget _buildInfoRow(String label, TextEditingController controller, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(controller.text.isEmpty ? 'Not provided' : controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onTap: () => _selectDate(context),
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_dobController.text.isEmpty ? 'Not provided' : _dobController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, bool isEditing, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          isEditing
              ? DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}