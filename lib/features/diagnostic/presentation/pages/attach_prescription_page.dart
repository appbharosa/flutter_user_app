import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:user/features/diagnostic/presentation/pages/add_patient_details_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../family_members_bloc/family_members_bloc.dart';



class AttachPrescriptionPage extends StatefulWidget {
  final int diagnosticId;
  final String diagnosticAddress;
  const AttachPrescriptionPage({
    super.key,
    required this.diagnosticId,
    required this.diagnosticAddress,
  });

  @override
  State<AttachPrescriptionPage> createState() => _AttachPrescriptionPageState();
}

class _AttachPrescriptionPageState extends State<AttachPrescriptionPage> {
  final List<File> _prescriptionFiles = [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _prescriptionFiles.add(File(picked.path)));
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => _prescriptionFiles.add(File(result.files.single.path!)));
    }
  }

  void _removeFile(int index) {
    setState(() => _prescriptionFiles.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attach Prescription',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,  // SemiBold
            fontFamily: 'Poppins',
          ),),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Prescription ',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const Icon(Icons.location_on, color: Colors.red, size: 20),
                    //     const SizedBox(width: 4),
                    //     Expanded(
                    //       child: Text(
                    //         widget.diagnosticAddress,
                    //         style: const TextStyle(
                    //           color: AppColors.black,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //           fontFamily: 'Poppins',
                    //         ),
                    //         softWrap: true,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 24),
                    // Upload buttons (Gallery, Camera, PDF) – matching PharmacyDetailPage style
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 20),
                            label: const Text('Gallery'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: const Text('Camera'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickPDF,
                            icon: const Icon(Icons.picture_as_pdf, size: 20),
                            label: const Text('PDF'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Selected files preview
                    if (_prescriptionFiles.isNotEmpty) ...[
                      const Text(
                        'Selected files:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _prescriptionFiles.length,
                          itemBuilder: (context, index) {
                            final file = _prescriptionFiles[index];
                            final isPDF = file.path.endsWith('.pdf');
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade200,
                                    image: !isPDF
                                        ? DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: isPDF
                                      ? const Center(
                                    child: Icon(Icons.picture_as_pdf, size: 40),
                                  )
                                      : null,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeFile(index),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Fixed bottom button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _prescriptionFiles.isEmpty
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => sl<FamilyMembersBloc>(),
                          child: AddPatientDetailsPage(
                            diagnosticId: widget.diagnosticId,
                            diagnosticAddress: widget.diagnosticAddress,
                            prescriptionPaths: _prescriptionFiles.map((f) => f.path).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}