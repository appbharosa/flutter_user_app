import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/med_locker_bloc.dart';
import '../bloc/med_locker_event.dart';
import '../bloc/med_locker_state.dart';
import 'add_med_locker_page.dart';
import 'med_locker_detail_page.dart';


class MedLockerListPage extends StatelessWidget {
  const MedLockerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MedLockerBloc>()..add(LoadMedLockers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Med Locker'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedLockerPage()),
                ).then((_) {
                  // Refresh list when returning
                  context.read<MedLockerBloc>().add(LoadMedLockers());
                });
              },
            ),
          ],
        ),
        body: BlocBuilder<MedLockerBloc, MedLockerState>(
          builder: (context, state) {
            if (state is MedLockerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedLockerLoaded) {
              if (state.lockers.isEmpty) {
                return const Center(child: Text('No med lockers yet. Tap + to add.'));
              }
              return ListView.builder(
                itemCount: state.lockers.length,
                itemBuilder: (context, index) {
                  final locker = state.lockers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: locker.images.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          locker.images.first.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                      )
                          : const Icon(Icons.medication, size: 40),
                      title: Text(locker.name),
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
    );
  }
}