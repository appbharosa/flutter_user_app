import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as sl;
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/med_locker_bloc.dart';
import '../bloc/med_locker_event.dart';
import '../bloc/med_locker_state.dart';
import 'med_locker_detail_page.dart';


class MedLockerListPage extends StatelessWidget {
  final bool isFromBottomNav; // Add this parameter

  const MedLockerListPage({
    Key? key,
    this.isFromBottomNav = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.sl<MedLockerBloc>()..add(LoadMedLockers()),
      child: Builder(
        builder: (context) {
          return SafeArea(
            top: false,
            bottom: true,
            child: Scaffold(
              appBar: AppBar(
                // Conditionally show leading back button
                leading: isFromBottomNav
                    ? null // No back button when from bottom navigation
                    : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => false,
                    );
                  },
                ),
                title: const Text(
                  'Med Locker',
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                centerTitle: isFromBottomNav, // Center title when no back button
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
              body: BlocListener<MedLockerBloc, MedLockerState>(
                listener: (context, state) {
                  if (state is MedLockerAddSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Med locker added successfully!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.read<MedLockerBloc>().add(LoadMedLockers());
                  } else if (state is MedLockerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: BlocBuilder<MedLockerBloc, MedLockerState>(
                  builder: (context, state) {
                    if (state is MedLockerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MedLockerListLoaded) {
                      if (state.lockers.isEmpty) {
                        return const Center(child: Text('No med lockers yet. Tap + to add.'));
                      }
                      return ListView.builder(
                        itemCount: state.lockers.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final locker = state.lockers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: locker.images.isNotEmpty
                                    ? Image.network(
                                  locker.images.first.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                                )
                                    : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.medication, size: 30),
                                ),
                              ),
                              title: Text(
                                locker.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${locker.images.length} image(s)'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MedLockerDetailPage(lockerId: locker.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (state is MedLockerError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.blue,
                onPressed: () => _showAddBottomSheet(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    final medLockerBloc = context.read<MedLockerBloc>();
    final nameController = TextEditingController();
    final List<File> selectedImages = [];
    final ImagePicker imagePicker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (innerContext, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Med Locker',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final List<XFile>? picked = await imagePicker.pickMultiImage();
                      if (picked != null && picked.isNotEmpty) {
                        setState(() {
                          selectedImages.clear();
                          selectedImages.addAll(picked.map((x) => File(x.path)));
                        });
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(
                      selectedImages.isEmpty
                          ? 'Select Images'
                          : '${selectedImages.length} image(s) selected',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: AppColors.blue,
                    ),
                  ),
                  if (selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (ctx, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImages[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            const SnackBar(content: Text('Please enter a name')),
                          );
                          return;
                        }
                        if (selectedImages.isEmpty) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            const SnackBar(content: Text('Please select at least one image')),
                          );
                          return;
                        }
                        Navigator.pop(modalContext);
                        medLockerBloc.add(AddMedLocker(name, List.from(selectedImages)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 46),
                ],
              ),
            );
          },
        );
      },
    );
  }
}