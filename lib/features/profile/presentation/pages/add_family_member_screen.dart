import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/utils/translations.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/add_family_member_request.dart';
import '../add_family_bloc/add_family_bloc.dart';
import '../add_family_bloc/add_family_state.dart';
import '../coverage_category_bloc/coverage_category_bloc.dart';
import '../coverage_category_bloc/coverage_category_state.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final int userId;
  const AddFamilyMemberScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  late AddFamilyBloc _addFamilyBloc;
  late CoverageCategoryBloc _coverageBloc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedBloodGroup = 'A+';
  int? _selectedCoverageId;
  String _selectedRelationship = 'Self';

  final List<String> _relationshipOptions = ['Mother', 'Father', 'Daughter', 'Wife', 'Son', 'Other'];

  int _getBloodGroupInt(String bloodGroup) {
    switch (bloodGroup) {
      case 'A+': return 1;
      case 'A-': return 2;
      case 'B+': return 3;
      case 'B-': return 4;
      case 'O+': return 5;
      case 'O-': return 6;
      case 'AB+': return 7;
      case 'AB-': return 8;
      default: return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _addFamilyBloc = di.sl<AddFamilyBloc>();
    _coverageBloc = di.sl<CoverageCategoryBloc>();
    _coverageBloc.add(LoadCoverageCategories('en'));
  }

  @override
  void dispose() {
    _addFamilyBloc.close();
    _coverageBloc.close();
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
    if (_formKey.currentState!.validate() && _selectedCoverageId != null) {
      final request = AddFamilyMemberRequest(
        userId: widget.userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        gender: _selectedGender,
        dob: _dobController.text,
        bloodGroup: _getBloodGroupInt(_selectedBloodGroup),
        coverageCategory: _selectedCoverageId!,
        relationship: _selectedRelationship,
      );
      _addFamilyBloc.add(SubmitAddFamily(request));
    } else if (_selectedCoverageId == null) {
      _showCustomSnackBar('Please select a coverage category', isError: true);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _addFamilyBloc),
        BlocProvider.value(value: _coverageBloc),
      ],
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          appBar: AppBar(
            title:  Text(
              'add_family_member'.tr(),
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
          ),
          body: BlocConsumer<AddFamilyBloc, AddFamilyState>(
            listener: (context, state) {
              if (state is AddFamilySuccess) {
                _showCustomSnackBar(state.message);
                Navigator.pop(context);
              } else if (state is AddFamilyError) {
                _showCustomSnackBar(state.message, isError: true);
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
                      _buildTextField(_nameController, 'name'.tr(), Icons.person),
                      _buildTextField(_emailController, 'email'.tr(), Icons.email),
                      _buildTextField(_mobileController, 'mobile'.tr(), Icons.phone, keyboardType: TextInputType.phone),
                      _buildDateField(),
                      _buildDropdown('gender'.tr(), _selectedGender, ['male', 'female'],
                              (value) => setState(() => _selectedGender = value!)),
                      _buildDropdown('blood_group'.tr(), _selectedBloodGroup,
                          ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                              (value) => setState(() => _selectedBloodGroup = value!)),
                      _buildCoverageDropdown(),
                      _buildDropdown('relationship'.tr(), _selectedRelationship, _relationshipOptions,
                              (value) => setState(() => _selectedRelationship = value!)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child:  Text('add_member'.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
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
        style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: AppColors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(fontSize: 14)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCoverageDropdown() {
    return BlocBuilder<CoverageCategoryBloc, CoverageCategoryState>(
      builder: (context, state) {
        if (state is CoverageCategoryLoading) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: const Row(
                children: [
                  SizedBox(width: 8),
                  Text('Loading coverage options...'),
                ],
              ),
            ),
          );
        } else if (state is CoverageCategoryLoaded) {
          if (state.categories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('No coverage categories available'),
            );
          }
          if (_selectedCoverageId == null && state.categories.isNotEmpty) {
            _selectedCoverageId = state.categories.first.id;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<int>(
              value: _selectedCoverageId,
              style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: AppColors.black),
              decoration: InputDecoration(
                labelText: 'coverage_category'.tr(),
                labelStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: state.categories.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(cat.name, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCoverageId = value;
                });
              },
              validator: (value) => value == null ? 'Please select a coverage category' : null,
            ),
          );
        } else if (state is CoverageCategoryError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
          );
        }
        return const SizedBox();
      },
    );
  }
}