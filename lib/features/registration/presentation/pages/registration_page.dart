import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/features/home/presentation/pages/home_page.dart';
import 'package:user/features/home/presentation/pages/widgets/add_address_screen.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/address_bloc/address_bloc.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'male';
  String _bloodGroup = '1';
  String _coverageCategory = '1';
  final _nomineeFullNameCtrl = TextEditingController();
  final _nomineeMobileCtrl = TextEditingController();
  final _nomineeDobCtrl = TextEditingController();
  String _nomineeRelationship = 'Son';
  String _nomineeGender = 'male';

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _coverageMap = {
    'Health Insurance': '1',
    'ESIC/EHS/CGHS': '2',
    'Aarogya Sree': '3',
    'Cash': '4',
    'Other': '5',
    'Aarogya Sree and Health Insurance': '6',
  };
  final Map<String, String> _bloodGroupMap = {
    'A+': '1', 'A-': '2', 'B+': '3', 'B-': '4',
    'O+': '5', 'O-': '6', 'AB+': '7', 'AB-': '8',
  };
  final List<String> _relationshipOptions = [
    'Father', 'Mother', 'Son', 'Daughter', 'Spouse', 'Other'
  ];

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _nameCtrl.text,
        'mobile': _mobileCtrl.text,
        'email': _emailCtrl.text,
        'gender': _gender,
        'dob': _dobCtrl.text,
        'blood_group': _bloodGroup,
        'coverage_category': _coverageCategory,
        'nominee_full_name': _nomineeFullNameCtrl.text,
        'nominee_mobile': _nomineeMobileCtrl.text,
        'nominee_date_of_birth': _nomineeDobCtrl.text,
        'nominee_relationship': _nomineeRelationship,
        'nominee_gender': _nomineeGender,
      };
      context.read<RegistrationBloc>().add(SubmitRegistration(userData));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _nomineeFullNameCtrl.dispose();
    _nomineeMobileCtrl.dispose();
    _nomineeDobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RegistrationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registration',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,  // SemiBold
            fontFamily: 'Poppins',
          ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
              );
              final addressBloc = sl<AddressBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAddressScreen(
                    addressBloc: addressBloc,
                    fromRegistration: true, //  important
                  ),
                ),
              );
            } else if (state is RegistrationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),


                    const SizedBox(height: 16),
                    _buildTextField(_nameCtrl, 'Full Name', required: true),
                    const SizedBox(height: 12),
                    _buildTextField(_mobileCtrl, 'Mobile Number', required: true, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField(_emailCtrl, 'Email', required: true, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _buildDateField(_dobCtrl, 'Date of Birth', required: true),
                    const SizedBox(height: 12),
                    _buildDropdown('Gender', _gender, (v) => setState(() => _gender = v!), ['male', 'female']),
                    const SizedBox(height: 12),
                    _buildDropdown('Blood Group', _bloodGroup, (v) => setState(() => _bloodGroup = v!),
                        _bloodGroupMap.entries.map((e) => e.value).toList(),
                        displayMapper: (val) => _bloodGroupMap.entries.firstWhere((e) => e.value == val).key),
                    const SizedBox(height: 12),
                    _buildDropdown('Coverage Category', _coverageCategory, (v) => setState(() => _coverageCategory = v!),
                        _coverageMap.entries.map((e) => e.value).toList(),
                        displayMapper: (val) => _coverageMap.entries.firstWhere((e) => e.value == val).key),

                    const SizedBox(height: 12),
                    const Text(
                      'Nominee Details ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_nomineeFullNameCtrl, 'Nominee Full Name', required: true),
                    const SizedBox(height: 12),
                    _buildTextField(_nomineeMobileCtrl, 'Nominee Mobile', required: true, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildDateField(_nomineeDobCtrl, 'Nominee DOB', required: true),
                    const SizedBox(height: 12),
                    _buildDropdown('Relationship', _nomineeRelationship, (v) => setState(() => _nomineeRelationship = v!), _relationshipOptions),
                    const SizedBox(height: 12),
                    _buildDropdown('Nominee Gender', _nomineeGender, (v) => setState(() => _nomineeGender = v!), ['male', 'female']),

                    const SizedBox(height: 32),
                    state is RegistrationLoading
                        ? const Center(child: CircularProgressIndicator())
                        :
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _submit(context),   // ✅ fixed
                        child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool required = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: required ? (v) => v == null || v.isEmpty ? '$label is required' : null : null,
    );
  }

  Widget _buildDateField(TextEditingController controller, String label,
      {bool required = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      readOnly: true,
      onTap: () => _selectDate(controller),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
      ),
      validator: required ? (v) => v == null || v.isEmpty ? '$label is required' : null : null,
    );
  }

  Widget _buildDropdown(String label, String value, Function(String?) onChanged, List<String> items,
      {String Function(String)? displayMapper}) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) {
        final display = displayMapper != null ? displayMapper(item) : item;
        return DropdownMenuItem(
          value: item,
          child: Text(display, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select $label' : null,
    );
  }
}