import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/lab_test.dart';
import '../../../../domain/entities/lab_test_package.dart';
import '../../../../domain/entities/lab_time_slot.dart';
import '../../../diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../lab_slot_bloc/lab_slot_bloc.dart';
import 'select_patient_for_package_page.dart';

class LabTestBookingPage extends StatelessWidget {
  final LabTest labTest;

  const LabTestBookingPage({super.key, required this.labTest});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LabSlotBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Lab Test'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _LabTestBookingContent(labTest: labTest),
      ),
    );
  }
}

class _LabTestBookingContent extends StatefulWidget {
  final LabTest labTest;
  const _LabTestBookingContent({required this.labTest});

  @override
  State<_LabTestBookingContent> createState() => _LabTestBookingContentState();
}

class _LabTestBookingContentState extends State<_LabTestBookingContent> {
  final List<File> _prescriptionFiles = [];
  DateTime _selectedDate = DateTime.now();
  LabTimeSlot? _selectedSlot;
  LabTestPackage? _selectedPackage;
  int? _selectedPersonCount;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  void _fetchSlots() {
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    context.read<LabSlotBloc>().add(LoadLabSlots(dateStr));
  }

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

  // Helper: get discounted price display
  String _getPriceDisplay(LabTestPackage pkg, int? persons) {
    if (persons == null) return '';
    num price = 0, discount = 0;
    switch (persons) {
      case 1:
        price = pkg.onePerson;
        discount = pkg.onePersonDiscount;
        break;
      case 2:
        price = pkg.twoPerson;
        discount = pkg.twoPersonDiscount;
        break;
      case 3:
        price = pkg.threePerson;
        discount = pkg.threePersonDiscount;
        break;
      case 4:
        price = pkg.fourPerson;
        discount = pkg.fourPersonDiscount;
        break;
      case 5:
        price = pkg.fivePerson;
        discount = pkg.fivePersonDiscount;
        break;
    }
    final priceDouble = price.toDouble();
    final discountDouble = discount.toDouble();
    if (discountDouble > 0) {
      final discounted = priceDouble - discountDouble;
      return '₹${priceDouble.toStringAsFixed(0)} → ₹${discounted.toStringAsFixed(0)} (save ₹${discountDouble.toStringAsFixed(0)})';
    } else {
      return '₹${priceDouble.toStringAsFixed(0)}';
    }
  }

  double _getTotalAmount(LabTestPackage pkg, int persons) {
    switch (persons) {
      case 1: return (pkg.onePerson - (pkg.onePersonDiscount ?? 0)).toDouble();
      case 2: return (pkg.twoPerson - (pkg.twoPersonDiscount ?? 0)).toDouble();
      case 3: return (pkg.threePerson - (pkg.threePersonDiscount ?? 0)).toDouble();
      case 4: return (pkg.fourPerson - (pkg.fourPersonDiscount ?? 0)).toDouble();
      case 5: return (pkg.fivePerson - (pkg.fivePersonDiscount ?? 0)).toDouble();
      default: return 0.0;
    }
  }

  void _showPackageBottomSheet(LabTimeSlot slot) {
    if (widget.labTest.packages.isEmpty) return;

    setState(() {
      _selectedSlot = slot;
      _selectedPackage = null;
      _selectedPersonCount = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('Select Package', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...widget.labTest.packages.map((pkg) {
                  final isSelected = _selectedPackage?.id == pkg.id;
                  final priceDisplay = _getPriceDisplay(pkg, _selectedPersonCount);
                  return Card(
                    elevation: isSelected ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSelected ? AppColors.blue : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<int>(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fasting: ${pkg.fasting} • Reports in: ${pkg.reportIn} days', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          if (priceDisplay.isNotEmpty) Text(priceDisplay, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                        ],
                      ),
                      value: pkg.id,
                      groupValue: _selectedPackage?.id,
                      onChanged: (val) => setStateSheet(() => _selectedPackage = pkg),
                      activeColor: AppColors.blue,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                const Text('Number of Persons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [1, 2, 3, 4, 5].map((count) {
                    final isSelected = _selectedPersonCount == count;
                    return ChoiceChip(
                      label: Text('$count'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setStateSheet(() {
                          _selectedPersonCount = selected ? count : null;
                          if (_selectedPackage != null) _selectedPackage = null; // reset package when persons change
                        });
                      },
                      selectedColor: AppColors.blue,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    onPressed: (_selectedPackage != null && _selectedPersonCount != null)
                        ? () {
                      Navigator.pop(context);
                      _navigateToFamilySelection();
                    }
                        : null,
                    child: const Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToFamilySelection() {
    if (_prescriptionFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload prescription'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final slot = _selectedSlot!;
    final package = _selectedPackage!;
    final persons = _selectedPersonCount!;
    final totalAmount = _getTotalAmount(package, persons);
    final selectedDateStr = _selectedDate.toIso8601String().split('T').first;
    final formattedDateStr = _formatDate(_selectedDate);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => sl<FamilyMembersBloc>(),
          child: SelectPatientForPackagePage(
            labTestId: widget.labTest.id,
            labTestAddress: widget.labTest.location,
            prescriptionPaths: _prescriptionFiles.map((f) => f.path).toList(),
            slotId: slot.slotId,
            slotTime: slot.time,
            selectedDate: selectedDateStr,
            formattedDate: formattedDateStr,
            packageId: package.id,
            packageName: package.name,
            packageFasting: package.fasting,
            packageReportIn: package.reportIn,
            personsCount: persons,
            totalAmount: totalAmount,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lab Address Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.location_on, color: AppColors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lab Address', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(widget.labTest.location, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Prescription Upload Section
          const Text('Upload Prescription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Upload prescription file (mandatory) - JPG, PNG, or PDF', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickPDF,
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text('PDF'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prescription Files Preview
          if (_prescriptionFiles.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Files', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
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
                              color: Colors.white,
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
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Date Selection
          const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.blue)), child: child!),
              );
              if (date != null && date != _selectedDate) {
                setState(() {
                  _selectedDate = date;
                  _selectedSlot = null;
                  _selectedPackage = null;
                  _selectedPersonCount = null;
                });
                _fetchSlots();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.blue, size: 20),
                      const SizedBox(width: 12),
                      Text('${_selectedDate.day} ${_getMonthAbbr(_selectedDate.month)} ${_selectedDate.year}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Slots Section
          const Text('Available Time Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          BlocBuilder<LabSlotBloc, LabSlotState>(
            builder: (context, state) {
              if (state is LabSlotLoading) return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
              if (state is LabSlotError) return Center(child: Column(children: [const Icon(Icons.error_outline, size: 48, color: Colors.red), const SizedBox(height: 8), Text(state.message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)]));
              if (state is LabSlotLoaded) {
                final slots = state.slots;
                if (slots.sessions.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No slots available on this date.')));
                return Column(
                  children: slots.sessions.map((session) {
                    final availableSlots = session.slots.where((s) => s.isAvailable && !s.isBooked).toList();
                    if (availableSlots.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Text(session.icon, style: const TextStyle(fontSize: 24)), const SizedBox(width: 8), Text(session.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: availableSlots.map((slot) {
                              final isSelected = _selectedSlot?.slotId == slot.slotId;
                              return FilterChip(
                                label: Text(slot.time),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) _showPackageBottomSheet(slot);
                                  else setState(() => _selectedSlot = null);
                                },
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: AppColors.blue.withOpacity(0.2),
                                checkmarkColor: AppColors.blue,
                                labelStyle: TextStyle(color: isSelected ? AppColors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: isSelected ? AppColors.blue : Colors.transparent, width: 1)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
