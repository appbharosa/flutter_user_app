import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_category_bloc/pharmacy_category_bloc.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_category_bloc/pharmacy_category_state.dart' hide PharmacyLoading;
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/pharmacy_category.dart';
import '../../../../domain/entities/pharmacy_product.dart';
import '../bloc/pharmacy_state.dart';
import '../pharmacy_category_bloc/pharmacy_category_event.dart';
import 'dart:async';

class PharmacyCategoryPage extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<Address?> addressNotifier;

  const PharmacyCategoryPage({
    super.key,
    required this.searchNotifier,
    required this.addressNotifier,
  });

  @override
  State<PharmacyCategoryPage> createState() => _PharmacyCategoryPageState();
}

class _PharmacyCategoryPageState extends State<PharmacyCategoryPage> {
  late PharmacyCategoryBloc _bloc;
  int? _selectedCategoryId;
  bool _showAllCategories = false;
  List<PharmacyCategory> _allCategories = [];
  String _searchQuery = "";
  int _currentImageIndex = 0;
  late Timer _autoScrollTimer;
  final List<String> _promoImages = [
    'assets/med_offer.png',
    'assets/scooter.png',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<PharmacyCategoryBloc>();
    _bloc.add(LoadPharmacyCategories());

    // Start auto‑scrolling timer (every 3 seconds)
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _promoImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    super.dispose();
  }

  // Filter categories by name (case‑insensitive)
  List<PharmacyCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _allCategories;
    return _allCategories.where((cat) =>
        cat.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Pharmacy",
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar for categories
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _showAllCategories = false;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search categories...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildAutoScrollImages(),
                const SizedBox(height: 20),

                // Categories Grid
                BlocBuilder<PharmacyCategoryBloc, PharmacyCategoryState>(
                  builder: (context, state) {
                    if (state is PharmacyCategoriesLoaded) {
                      _allCategories = state.categories;
                      return _buildCategoriesGrid();
                    }
                    if (state is PharmacyCategoryError) {
                      return Center(child: Text(state.message));
                    }
                    if (_allCategories.isEmpty && state is PharmacyLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_allCategories.isNotEmpty) {
                      return _buildCategoriesGrid();
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 20),

                // Offer Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xff0057FF), Color(0xff1F6BFF)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Flat 20% OFF\non Medicines", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Use Code: MED20", style: TextStyle(color: Colors.white70)),
                          Text("*T&C Apply", style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                      Image.asset(
                        "assets/offer_badge.png",
                        height: 60,
                        errorBuilder: (_, __, ___) => const Icon(Icons.local_offer, color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Popular Medicines Heading
                const Text(
                  "Popular Medicines",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Products List
                BlocBuilder<PharmacyCategoryBloc, PharmacyCategoryState>(
                  builder: (context, state) {
                    if (state is PharmacyProductsLoaded) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text("No products in this category"));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildProductCard(state.products[index]),
                      );
                    }
                    if (state is PharmacyLoading && _selectedCategoryId != null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 30),

                // Footer Icons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFooterIcon(Icons.verified, "100% Genuine\nMedicines"),
                      _buildFooterIcon(Icons.currency_rupee, "Best\nPrices"),
                      _buildFooterIcon(Icons.local_shipping, "Fast\nDelivery"),
                      _buildFooterIcon(Icons.support_agent, "24x7\nSupport"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoScrollImages() {
    return SizedBox(
      height: 180, // Adjust height as needed
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 1.0),  // start from bottom
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
            return SlideTransition(position: offset, child: child);
          },
          child: Image.asset(
            _promoImages[_currentImageIndex],
            key: ValueKey<int>(_currentImageIndex),
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final filtered = _filteredCategories;
    if (filtered.isEmpty) {
      return const Center(child: Text("No categories match your search"));
    }

    List<PharmacyCategory> displayCategories;
    if (_showAllCategories) {
      displayCategories = filtered;
    } else {
      displayCategories = filtered.take(6).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
          ),
          itemCount: _showAllCategories
              ? displayCategories.length
              : (displayCategories.length + (filtered.length > 6 ? 1 : 0)),
          itemBuilder: (context, index) {
            if (!_showAllCategories && index == displayCategories.length && filtered.length > 6) {
              return _buildViewAllTile();
            }
            final category = displayCategories[index];
            final isSelected = _selectedCategoryId == category.id;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategoryId = category.id);
                _bloc.add(LoadPharmacyProducts(category.id));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.blue : Colors.grey.shade200,
                    width: 1,
                  ),
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
                        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                      ),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.blue : Colors.black87,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildViewAllTile() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllCategories = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blue, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_view, size: 45, color: AppColors.blue),
            const SizedBox(height: 8),
            const Text(
              "View All",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(PharmacyProduct product) {
    final discountPercent = product.discountPercent;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: product.image,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 80,
                width: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 80,
                width: 80,
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
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (product.type.isNotEmpty)
                  Text(product.type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (product.description.isNotEmpty)
                  Text(product.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "₹${product.discountPrice}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "₹${product.price}",
                      style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
                    ),
                    if (discountPercent > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${discountPercent.toStringAsFixed(0)}% OFF",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add to cart or product detail
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text("Add", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.blue, size: 26),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}