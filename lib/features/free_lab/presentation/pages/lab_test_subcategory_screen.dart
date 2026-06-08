import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/free_lab_package.dart';
import '../lab_test_subcategory_bloc/lab_test_subcategory_bloc.dart';
import '../lab_test_subcategory_bloc/lab_test_subcategory_event.dart';
import '../lab_test_subcategory_bloc/lab_test_subcategory_state.dart';
import 'free_lab_packages_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LabTestSubcategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final ValueNotifier<Address?> addressNotifier;

  const LabTestSubcategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.addressNotifier,
  });

  @override
  State<LabTestSubcategoryScreen> createState() => _LabTestSubcategoryScreenState();
}

class _LabTestSubcategoryScreenState extends State<LabTestSubcategoryScreen> {
  late LabTestSubcategoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<LabTestSubcategoryBloc>();
    _bloc.add(LoadPackagesByCategory(categoryId: widget.categoryId, language: 'en'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<LabTestSubcategoryBloc, LabTestSubcategoryState>(
          builder: (context, state) {
            if (state is LabTestSubcategoryLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.blue));
            }
            if (state is LabTestSubcategoryError) {
              return _buildErrorState(state.message);
            }
            if (state is LabTestSubcategoryLoaded) {
              if (state.packages.isEmpty) {
                return _buildEmptyState();
              }
              return _buildPackageList(state.packages);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.blue),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _bloc.add(LoadPackagesByCategory(
                categoryId: widget.categoryId,
                language: 'en',
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 48, color: AppColors.blue),
          const SizedBox(height: 12),
          const Text(
            'No packages found in this category',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageList(List<FreeLabPackage> packages) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: packages.length,
      itemBuilder: (context, index) => _buildPackageCard(packages[index]),
    );
  }

  Widget _buildPackageCard(FreeLabPackage package) {
    return Card(
      color: AppColors.whiteColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildPackageImage(package.image),
                  ),
                ),
                const SizedBox(width: 12),

                // Package Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Price Row
                      Row(
                        children: [
                          Text(
                            '₹${package.discountPrice}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${package.price}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.5),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Details Row
                      Row(
                        children: [
                          const Icon(Icons.description, size: 14, color: AppColors.blue),
                          const SizedBox(width: 4),
                          Flexible(  // Changed from Text to Flexible
                            child: Text(
                              'Report: ${package.reportIn ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,  // Added overflow handling
                              maxLines: 1,  // Added max lines
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.fastfood, size: 14, color: AppColors.blue),
                          const SizedBox(width: 4),
                          Flexible(  // Changed from Text to Flexible
                            child: Text(
                              'Fasting: ${package.fasting ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,  // Added overflow handling
                              maxLines: 1,  // Added max lines
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Book Button
                ElevatedButton(
                  onPressed: () => _navigateToDetail(package.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Book",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 1, color: Colors.blue),
          ),

          // Tests Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '${package.packageTests.length} Tests Included',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ),

          // Test List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: package.packageTests.length,
            itemBuilder: (context, index) => _buildTestTile(package.packageTests[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.medical_services, color: AppColors.blue, size: 24),
      );
    }

    if (imageUrl.endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 1.5),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.medical_services, color: AppColors.blue, size: 24),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 1.5),
        );
      },
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.medical_services, color: AppColors.blue, size: 24),
      ),
    );
  }

  Widget _buildTestTile(PackageTest test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          initiallyExpanded: false,
          childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          title: Text(
            test.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.arrow_drop_down, color: AppColors.blue, size: 20),
          children: test.parameters.isEmpty
              ? [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No parameters available',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ]
              : test.parameters.map((param) => _buildParameterTile(param)).toList(),
        ),
      ),
    );
  }

  Widget _buildParameterTile(TestParameter param) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue,
            ),
          ),
          Expanded(
            child: Text(
              param.name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(int packageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreeLabPackagesScreen(
          addressNotifier: widget.addressNotifier,
          packageId: packageId,
        ),
      ),
    );
  }
}