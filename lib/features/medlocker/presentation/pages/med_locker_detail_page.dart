import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/med_locker_bloc.dart';
import '../bloc/med_locker_event.dart';
import '../bloc/med_locker_state.dart';

import '../../../../core/di/injection.dart';


class MedLockerDetailPage extends StatelessWidget {
  final int lockerId;
  const MedLockerDetailPage({super.key, required this.lockerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MedLockerBloc>()..add(LoadMedLockerDetail(lockerId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Med Locker Details',
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
        body: BlocBuilder<MedLockerBloc, MedLockerState>(
          builder: (context, state) {
            if (state is MedLockerDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedLockerDetailLoaded) {
              final detail = state.detail;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Status: ${detail.status == 1 ? "Active" : "Inactive"}'),
                              ],
                            ),
                            if (detail.alertDate != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.notifications, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Alert: ${detail.alertDate}'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Images',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    if (detail.images.isEmpty)
                      const Center(child: Text('No images available'))
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: detail.images.length,
                        itemBuilder: (context, index) {
                          final image = detail.images[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              image.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            } else if (state is MedLockerError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MedLockerBloc>().add(LoadMedLockerDetail(lockerId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}