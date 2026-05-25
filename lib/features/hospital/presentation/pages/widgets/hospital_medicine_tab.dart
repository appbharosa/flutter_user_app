import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/entities/hospital_main_data.dart';
import 'medicine_confirm_screen.dart';


class HospitalMedicineTab extends StatefulWidget {
  final HospitalMainData hospital;
  final int addressId;
  const HospitalMedicineTab({super.key, required this.hospital, required this.addressId});

  @override
  State<HospitalMedicineTab> createState() => _HospitalMedicineTabState();
}

class _HospitalMedicineTabState extends State<HospitalMedicineTab> {
  final List<File> _prescriptionFiles = [];
  String? _selectedOrderType;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked != null) setState(() => _prescriptionFiles.add(File(picked.path)));
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) setState(() => _prescriptionFiles.add(File(result.files.single.path!)));
  }

  void _removeFile(int index) => setState(() => _prescriptionFiles.removeAt(index));

  Future<void> _showOrderTypeBottomSheet() async {
    if (_prescriptionFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload prescription'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Order Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: AppColors.blue),
              title: const Text('Home Delivery'),
              onTap: () => Navigator.pop(context, 'home_delivery'),
            ),
            ListTile(
              leading: const Icon(Icons.store, color: AppColors.blue),
              title: const Text('Pickup'),
              onTap: () => Navigator.pop(context, 'pickup'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      _selectedOrderType = selected;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineConfirmScreen(
            hospital: widget.hospital,
            orderType: selected,
            prescriptionPaths: _prescriptionFiles.map((f) => f.path).toList(),
            addressId: widget.addressId,
          ),
        ),
      );
    }
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          // Location card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.hospital.location,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Prescription title
          const Text(
            'Upload Prescription',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppColors.black,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // File preview
          if (_prescriptionFiles.isNotEmpty) ...[
            const Text('Selected files:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _prescriptionFiles.length,
                itemBuilder: (context, index) => Stack(
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
                        image: _prescriptionFiles[index].path.endsWith('.pdf')
                            ? null
                            : DecorationImage(image: FileImage(_prescriptionFiles[index]), fit: BoxFit.cover),
                      ),
                      child: _prescriptionFiles[index].path.endsWith('.pdf')
                          ? const Center(child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red))
                          : null,
                    ),
                    Positioned(
                      top: -8,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeFile(index),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showOrderTypeBottomSheet,
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}