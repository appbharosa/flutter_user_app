

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/hospital_main_data.dart';
import 'diagnostic_family_selection_screen.dart';

class HospitalDiagnosticTab extends StatefulWidget {
  final HospitalMainData hospital;
  final int addressId;

  const HospitalDiagnosticTab({
    Key? key,
    required this.hospital,
    required this.addressId,
  }) : super(key: key);

  @override
  State<HospitalDiagnosticTab> createState() => _HospitalDiagnosticTabState();
}

class _HospitalDiagnosticTabState extends State<HospitalDiagnosticTab> {
  final List<File> _prescriptionFiles = [];

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _prescriptionFiles.add(File(picked.path));
      });
    }
  }

  // Pick PDF or other files
  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        _prescriptionFiles.add(File(result.files.single.path!));
      });
    }
  }

  // Remove a file from the list
  void _removeFile(int index) {
    setState(() {
      _prescriptionFiles.removeAt(index);
    });
  }

  // Directly proceed to family selection without order type
  void _proceedToFamilySelection() {
    if (_prescriptionFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a prescription'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalDiagnosticFamilySelection(
          hospitalId: widget.hospital.id,
          addressId: widget.addressId,
          prescriptionPaths: _prescriptionFiles.map((f) => f.path).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timing card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⏰ Timing: ${widget.hospital.openTime} - ${widget.hospital.closeTime}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),

          // Location card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.hospital.location,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Prescription title
          const Text(
            'Upload Prescription',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),

          // Upload buttons – rounded with border
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blue),
                    foregroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blue),
                    foregroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickPDF,
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blue),
                    foregroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // File preview (horizontal scroll)
          if (_prescriptionFiles.isNotEmpty) ...[
            const Text(
              'Selected files:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _prescriptionFiles.length,
                itemBuilder: (context, index) {
                  final file = _prescriptionFiles[index];
                  final isPdf = file.path.toLowerCase().endsWith('.pdf');
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          image: isPdf
                              ? null
                              : DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: isPdf
                            ? const Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            size: 40,
                            color: Colors.red,
                          ),
                        )
                            : null,
                      ),
                      Positioned(
                        top: -8,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeFile(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Continue button – now directly proceeds without order type
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _proceedToFamilySelection,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}