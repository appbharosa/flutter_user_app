import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/pharmacy.dart';
import 'order_confirm_screen.dart';

class PharmacyDetailPage extends StatefulWidget {
  final Pharmacy pharmacy;
  final ValueNotifier<Address?> addressNotifier;

  const PharmacyDetailPage({
    super.key,
    required this.pharmacy,
    required this.addressNotifier,
  });

  @override
  State<PharmacyDetailPage> createState() => _PharmacyDetailPageState();
}

class _PharmacyDetailPageState extends State<PharmacyDetailPage> {
  final List<File> _prescriptionFiles = [];

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _prescriptionFiles.add(File(picked.path));
      });
    }
  }

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

  void _removeFile(int index) {
    setState(() {
      _prescriptionFiles.removeAt(index);
    });
  }

  void _showOrderTypeBottomSheet() {
    if (_prescriptionFiles.isEmpty) {
      _showSnackBar('Prescription is mandatory', isError: true);
      return;
    }
    final address = widget.addressNotifier.value;
    if (address == null) {
      _showSnackBar('Please select an address first', isError: true);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Order Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.blue),
              title: const Text('Home Delivery'),
              onTap: () {
                Navigator.pop(context);
                _proceedToConfirm('home_delivery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.store, color: Colors.blue),
              title: const Text('Pickup'),
              onTap: () {
                Navigator.pop(context);
                _proceedToConfirm('pickup');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToConfirm(String orderType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmScreen(
          pharmacy: widget.pharmacy,
          orderType: orderType,
          prescriptionFiles: _prescriptionFiles,
          address: widget.addressNotifier.value!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pharmacy.name,style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,  // SemiBold
          fontFamily: 'Poppins',
        ),),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pharmacy logo
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.pharmacy.logo,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.pharmacy.openTime != null && widget.pharmacy.closeTime != null)
                    Text(
                      '⏰ ${widget.pharmacy.openTime} - ${widget.pharmacy.closeTime}',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,  // SemiBold
                          fontFamily: 'Poppins',
                        ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.pharmacy.location,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Upload Prescription ',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,  // SemiBold
                        fontFamily: 'Poppins',
                      ),
                  ),
                  const SizedBox(height: 12),
                  // Stylish buttons row
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
                  const SizedBox(height: 16),
                  // Selected files preview
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
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                  image: file.path.endsWith('.pdf')
                                      ? null
                                      : DecorationImage(
                                    image: FileImage(file),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: file.path.endsWith('.pdf')
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Bottom button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showOrderTypeBottomSheet,
                child: const Text(
                  'Book Medicine',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,  // SemiBold
                      fontFamily: 'Poppins',
                    ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}