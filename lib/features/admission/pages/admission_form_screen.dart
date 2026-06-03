import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/admission_request.dart';
import '../../home/presentation/pages/home_page.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';



class AdmissionFormScreen extends StatefulWidget {
  const AdmissionFormScreen({Key? key}) : super(key: key);

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _locationController = TextEditingController();

  String _gender = 'Male';
  String _department = 'Cardiology';
  String _admissionType = 'Planned Admission';

  final List<String> _departments = [
    'Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics',
    'General Medicine', 'Surgery'
  ];

  final List<File> _prescriptionFiles = [];
  final List<File> _reportsFiles = [];
  final List<File> _insuranceFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFiles(String type) async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked != null) {
      setState(() {
        final files = picked.map((x) => File(x.path)).toList();
        if (type == 'prescription') _prescriptionFiles.addAll(files);
        else if (type == 'reports') _reportsFiles.addAll(files);
        else _insuranceFiles.addAll(files);
      });
    }
  }

  void _removeFile(String type, int index) {
    setState(() {
      if (type == 'prescription') _prescriptionFiles.removeAt(index);
      else if (type == 'reports') _reportsFiles.removeAt(index);
      else _insuranceFiles.removeAt(index);
    });
  }

  void _showRoundedSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AdmissionBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Admission Support', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.whiteColor)),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<AdmissionBloc, AdmissionState>(
          listener: (context, state) {
            if (state is AdmissionSuccess) {
              _showRoundedSnackBar('Admission request submitted successfully!');
              // Navigate to HomePage and clear all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
              );
            } else if (state is AdmissionError) {
              _showRoundedSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Patient Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildTextField(_patientNameController, 'Patient Name'),
                        _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number),
                        _buildDropdown('Gender', _gender, ['Male', 'Female', 'Other'], (value) => setState(() => _gender = value!)),
                        _buildTextField(
                          _mobileController,
                          'Mobile Number',
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          customValidator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter mobile number';
                            if (value.length != 10) return 'Mobile number must be exactly 10 digits';
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Please enter only digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        const Text('Medical Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildTextField(_symptomsController, 'Symptoms / Diagnosis', maxLines: 3),
                        _buildDropdown('Department Required', _department, _departments, (value) => setState(() => _department = value!)),
                        const SizedBox(height: 8),
                        const Text('Admission Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('Emergency Admission'),
                              value: 'Emergency Admission',
                              groupValue: _admissionType,
                              onChanged: (value) => setState(() => _admissionType = value!),
                              activeColor: AppColors.blue,
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<String>(
                              title: const Text('Planned Admission'),
                              value: 'Planned Admission',
                              groupValue: _admissionType,
                              onChanged: (value) => setState(() => _admissionType = value!),
                              activeColor: AppColors.blue,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Preferred Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildTextField(_locationController, 'Location (City / Area)'),
                        const SizedBox(height: 24),

                        const Text('Upload Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildFileUploadSection('Prescription', _prescriptionFiles, () => _pickFiles('prescription'), (i) => _removeFile('prescription', i)),
                        _buildFileUploadSection('Reports', _reportsFiles, () => _pickFiles('reports'), (i) => _removeFile('reports', i)),
                        _buildFileUploadSection('Insurance Card', _insuranceFiles, () => _pickFiles('insurance'), (i) => _removeFile('insurance', i)),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final request = AdmissionRequest(
                                  patientName: _patientNameController.text.trim(),
                                  age: int.tryParse(_ageController.text.trim()) ?? 0,
                                  gender: _gender,
                                  phone: _mobileController.text.trim(),
                                  symptoms: _symptomsController.text.trim(),
                                  departmentRequired: _department,
                                  admissionType: _admissionType,
                                  preferredLocation: _locationController.text.trim(),
                                  prescriptionPaths: _prescriptionFiles.map((f) => f.path).toList(),
                                  reportsPaths: _reportsFiles.map((f) => f.path).toList(),
                                  insuranceCardPaths: _insuranceFiles.map((f) => f.path).toList(),
                                );
                                context.read<AdmissionBloc>().add(SubmitAdmissionEvent(request));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (state is AdmissionLoading)
                  Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
              ],
            );
          },
        ),
      ),
    );
  }

  // ... (all helper widgets: _buildTextField, _buildDropdown, _buildFileUploadSection remain exactly the same as before)
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, int maxLines = 1, int? maxLength, String? Function(String?)? customValidator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          counterText: maxLength != null ? null : '',
        ),
        validator: customValidator ?? (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildFileUploadSection(String title, List<File> files, VoidCallback onPick, Function(int) onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
              TextButton.icon(onPressed: onPick, icon: const Icon(Icons.upload), label: const Text('Upload')),
            ],
          ),
          if (files.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                itemBuilder: (ctx, i) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: FileImage(files[i]), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(),
        ],
      ),
    );
  }
}