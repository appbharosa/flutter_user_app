import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../data/data_sources/free_lab_remote_datasource.dart';
import '../../../../data/models/free_lab_package_model.dart';
import '../../../../domain/entities/address.dart';
import '../../../free_lab/presentation/lab_test_category_bloc/lab_test_category_bloc.dart';
import '../../../free_lab/presentation/lab_test_category_bloc/lab_test_category_event.dart';
import '../../../free_lab/presentation/lab_test_category_bloc/lab_test_category_state.dart';
import '../../../free_lab/presentation/pages/free_lab_packages_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../domain/entities/lab_test_category.dart';
import '../../../free_lab/presentation/pages/lab_test_subcategory_screen.dart';



class LabTestScreen extends StatefulWidget {
  final ValueNotifier<Address?> addressNotifier;

  const LabTestScreen({super.key, required this.addressNotifier});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  late Future<List<FreeLabPackageModel>> _packagesFuture;
  late FreeLabRemoteDataSource _dataSource;
  bool _showAllCategories = false; // toggle for category expansion

  @override
  void initState() {
    super.initState();
    _dataSource = di.sl<FreeLabRemoteDataSource>();
    _packagesFuture = _fetchPackages();
  }

  Future<List<FreeLabPackageModel>> _fetchPackages() async {
    try {
      final language = 'en'; // or get from LanguageService
      return await _dataSource.getFreeLabPackages(language);
    } catch (e) {
      throw Exception('Failed to load packages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = 'en';
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xff0057FF), Color(0xff0039CB)]),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Lab & Diagnostics",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<FreeLabPackageModel>>(
        future: _packagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _packagesFuture = _fetchPackages()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No lab packages available'));
          }

          final packages = snapshot.data!;
          final popularPackages = packages.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search + top buttons (static)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search tests, packages or health checkups...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _topButton(Icons.upload, "Upload\nPrescription"),
                    const SizedBox(width: 10),
                    _topButton(Icons.home_outlined, "Book Home\nVisit"),
                  ],
                ),
                const SizedBox(height: 16),

                // Banner image (static PNG)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    "assets/lab.jpeg",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),

                // 🟢 CATEGORIES GRID (first 10 + optional "View All")
                BlocProvider(
                  create: (context) => di.sl<LabTestCategoryBloc>()..add(LoadLabTestCategories(language: language)),
                  child: BlocBuilder<LabTestCategoryBloc, LabTestCategoryState>(
                    builder: (context, catState) {
                      if (catState is LabTestCategoryLoading) {
                        return const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (catState is LabTestCategoryError) {
                        return const SizedBox(
                          height: 120,
                          child: Center(child: Text('Failed to load categories')),
                        );
                      }
                      if (catState is LabTestCategoryLoaded) {
                        final categories = catState.categories;
                        if (categories.isEmpty) return const SizedBox.shrink();

                        // Determine which categories to display
                        List<Widget> gridChildren = [];
                        final displayCategories = _showAllCategories
                            ? categories
                            : categories.take(10).toList();

                        // Add category tiles
                        gridChildren.addAll(
                          displayCategories.map((cat) => _categoryItemFromApi(cat)).toList(),
                        );

                        // If not showing all and we have more than 10, add "View All" tile
                        if (!_showAllCategories && categories.length > 10) {
                          gridChildren.add(_viewAllTile());
                        }

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: gridChildren,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Offer cards (static)
                Row(
                  children: [
                    Expanded(child: _offerCard(Colors.green.shade50, "Home Sample Collection", "FREE on orders above ₹299")),
                    const SizedBox(width: 12),
                    Expanded(child: _offerCard(Colors.purple.shade50, "Best Prices", "Affordable Packages")),
                  ],
                ),
                const SizedBox(height: 24),

                // Popular Tests & Packages (dynamic)
                const Text(
                  "Popular Tests & Packages",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularPackages.length,
                    itemBuilder: (context, index) => _dynamicPackageCard(popularPackages[index]),
                  ),
                ),
                const SizedBox(height: 24),

                // All Lab Packages (dynamic list)
                const Text(
                  "All Lab Packages",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: packages.length,
                  itemBuilder: (context, index) => _allPackageTile(packages[index]),
                ),
                const SizedBox(height: 24),

                // Why choose section (static)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WhyItem(icon: Icons.verified, title: "100%\nAccurate"),
                      _WhyItem(icon: Icons.currency_rupee, title: "Best\nPrices"),
                      _WhyItem(icon: Icons.access_time, title: "Quick\nReports"),
                      _WhyItem(icon: Icons.lock, title: "Secure"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Static helper widgets ----------
  static Widget _topButton(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _offerCard(Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Text(subtitle),
        ],
      ),
    );
  }

  // "View All" tile – looks like a category tile but with a distinct style
  Widget _viewAllTile() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllCategories = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_view, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            const Text(
              "View All",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  // Category item from API (supports SVG)
  Widget _categoryItemFromApi(LabTestCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabTestSubcategoryScreen(
              categoryId: category.id,
              categoryName: category.name,
              addressNotifier: widget.addressNotifier,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.network(
              category.image,
              height: 30,
              width: 30,
              placeholderBuilder: (context) => const SizedBox(
                height: 30,
                width: 30,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic card: horizontal popular package
  Widget _dynamicPackageCard(FreeLabPackageModel package) {
    double discountPercent = 0;
    final original = double.tryParse(package.price) ?? 0;
    final discounted = double.tryParse(package.discountPrice) ?? 0;
    if (original > 0 && discounted > 0) {
      discountPercent = ((original - discounted) / original) * 100;
    }

    return GestureDetector(
      onTap: () => _navigateToDetail(package.id),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 38),
            const SizedBox(height: 10),
            Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2),
            const Spacer(),
            Text('₹${package.discountPrice}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (discountPercent > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${discountPercent.toStringAsFixed(0)}% OFF', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToDetail(package.id),
                child: const Text("Book Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic tile: vertical list of all packages
  Widget _allPackageTile(FreeLabPackageModel package) {
    return GestureDetector(
      onTap: () => _navigateToDetail(package.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: package.image,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('₹${package.discountPrice}  (₹${package.price})', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Report: ${package.reportIn} • Fasting: ${package.fasting}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _navigateToDetail(package.id),
              child: const Text("Book"),
            ),
          ],
        ),
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

class _WhyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _WhyItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 34),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}