import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/add_family_member_request.dart';
import '../add_family_bloc/add_family_bloc.dart';
import '../add_family_bloc/add_family_state.dart';


class AddFamilyMemberScreen extends StatefulWidget {
  final int userId;
  const AddFamilyMemberScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  late AddFamilyBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedBloodGroup = 'A+';
  String _selectedCoverage = 'Health Insurance';
  String _selectedRelationship = 'Self';

  final List<String> _relationshipOptions = ['Mother', 'Father', 'Daughter', 'Wife', 'Son', 'Other'];

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<AddFamilyBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dobController.text = picked.toIso8601String().split('T').first);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = AddFamilyMemberRequest(
        userId: widget.userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        gender: _selectedGender,
        dob: _dobController.text,
        bloodGroup: _selectedBloodGroup,
        coverageCategory: _selectedCoverage,
        relationship: _selectedRelationship,
      );
      _bloc.add(SubmitAddFamily(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Family Member',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 17,
            fontWeight: FontWeight.w500,  // SemiBold
            fontFamily: 'Poppins',
          ),),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<AddFamilyBloc, AddFamilyState>(
          listener: (context, state) {
            if (state is AddFamilySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              Navigator.pop(context);
            } else if (state is AddFamilyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is AddFamilyLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Name', Icons.person),
                    _buildTextField(_emailController, 'Email', Icons.email),
                    _buildTextField(_mobileController, 'Mobile', Icons.phone, keyboardType: TextInputType.phone),
                    _buildDateField(),
                    _buildDropdown('Gender', _selectedGender, ['male', 'female'], (value) => setState(() => _selectedGender = value!)),
                    _buildDropdown('Blood Group', _selectedBloodGroup, ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'], (value) => setState(() => _selectedBloodGroup = value!)),
                    _buildDropdown('Coverage Category', _selectedCoverage, [
                      'Health Insurance', 'ESIC/EHS/CGHS', 'Aarogya Sree', 'Cash', 'Other', 'Aarogya Sree and Health Insurance'
                    ], (value) => setState(() => _selectedCoverage = value!)),
                    _buildDropdown('Relationship', _selectedRelationship, _relationshipOptions, (value) => setState(() => _selectedRelationship = value!)),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Add Member', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: _selectDate,
        validator: (value) => value == null || value.isEmpty ? 'Please select date of birth' : null,
      ),
    );
  }


  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        style: const TextStyle(fontSize: 14, fontFamily: 'Poppins',color: AppColors.black), // smaller selected value text
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14), // smaller label
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(fontSize: 14)), // smaller menu item text
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}