import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/free_lab_package.dart';
import '../bloc/free_lab_packages_bloc/free_lab_packages_bloc.dart';
import '../bloc/free_lab_packages_bloc/free_lab_packages_event.dart';
import '../bloc/free_lab_packages_bloc/free_lab_packages_state.dart';
import 'free_lab_slots_screen.dart';



class FreeLabPackagesScreen extends StatefulWidget {
  final ValueNotifier<Address?> addressNotifier;
  final FreeLabPackage package; // ✅ now required

  const FreeLabPackagesScreen({
    Key? key,
    required this.addressNotifier,
    required this.package,
  }) : super(key: key);

  @override
  State<FreeLabPackagesScreen> createState() => _FreeLabPackagesScreenState();
}

class _FreeLabPackagesScreenState extends State<FreeLabPackagesScreen> {
  late FreeLabPackagesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<FreeLabPackagesBloc>();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final language = await LanguageService.getCurrentLanguage();
    _bloc.add(LoadFreeLabPackages(language));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: Text(
            widget.package.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppColors.whiteColor,
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<FreeLabPackagesBloc, FreeLabPackagesState>(
          listener: (context, state) {
            if (state is FreeLabPackagesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is FreeLabPackagesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FreeLabPackagesLoaded) {
              return _buildContent(widget.package);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(FreeLabPackage package) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Image ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: package.image,
                height: 180,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(color: Colors.grey.shade200),
                errorWidget: (_, __, ___) => const Icon(Icons.medical_services, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Name ──────────────────────────────────────────────────
          Text(
            package.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // ─── Price ──────────────────────────────────────────────────
          Row(
            children: [
              Text(
                '₹${package.price}',
                style: const TextStyle(fontSize: 13, decoration: TextDecoration.lineThrough, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${package.discountPrice}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ─── Info Chips ──────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.access_time, 'Report: ${package.reportIn}'),
              _buildInfoChip(Icons.fastfood, 'Fasting: ${package.fasting}'),
              _buildInfoChip(Icons.people, package.suitableFor),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Tests Included ──────────────────────────────────────────
          const Text(
            'Tests Included',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: package.packageTests.length,
            itemBuilder: (context, index) {
              final test = package.packageTests[index];
              return _buildExpandableTestCard(test);
            },
          ),
          const SizedBox(height: 24),

          // ─── Book Now Button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreeLabSlotsScreen(
                      packageId: package.id,
                      packageName: package.name,
                      hygienicKitCharges: package.hygienicKitCharges,
                      packageDiscountPrice: package.discountPrice,
                      addressNotifier: widget.addressNotifier,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.blue),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.blue)),
        ],
      ),
    );
  }

  Widget _buildExpandableTestCard(PackageTest test) {
    return Card(
      color: AppColors.whiteColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            test.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          children: test.parameters.isEmpty
              ? [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No parameters available', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ]
              : test.parameters.map((param) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    param.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}