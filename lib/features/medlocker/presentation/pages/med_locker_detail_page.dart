import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../detail_bloc/med_locker_detail_bloc.dart';
import '../detail_bloc/med_locker_detail_event.dart';
import '../detail_bloc/med_locker_detail_state.dart';


class MedLockerDetailPage extends StatelessWidget {
  final int lockerId;
  const MedLockerDetailPage({super.key, required this.lockerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MedLockerDetailBloc>()..add(LoadMedLockerDetail(lockerId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Med Locker Details'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<MedLockerDetailBloc, MedLockerDetailState>(
          builder: (context, state) {
            if (state is MedLockerDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedLockerDetailLoaded) {
              final locker = state.locker;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locker.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (locker.images.isNotEmpty) ...[
                      const Text('Images:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: locker.images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  locker.images[index].imageUrl,
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            } else if (state is MedLockerDetailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}