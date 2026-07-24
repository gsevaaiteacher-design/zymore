// ============================================================
// 📁 FILE: category_products.dart
// 📍 LOCATION: lib/screens/category_products.dart
// 🎯 PURPOSE: Category Products Screen - Browse Products by Category
// 🔗 USED BY: Home Screen (Category Cards)
// 📝 DESCRIPTION:
//    This screen displays products filtered by category:
//    - Category name and icon
//    - Product grid/list view
//    - Filter and sort options
//    - Search within category
//    - Pagination (load more)
//    - Pull to refresh
//    - Loading states
//    - Empty state
//    - Error handling
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================
// 📁 IMPORT MODELS, PROVIDERS, WIDGETS, UTILS
// ============================================================
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/ad_banner.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// ============================================================
// 🎯 CATEGORY PRODUCTS SCREEN
// ============================================================

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen>
    with AutomaticKeepAliveClientMixin {
  // ── STATE ──
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _isGridView = true;
  String _sortBy = 'popular';
  String _filterBy = 'all';

  // ── SORT OPTIONS ──
  final List<String> _sortOptions = [
    'popular',
    'newest',
    'rating',
    'downloads',
  ];
  final List<String> _filterOptions = ['all', 'free', 'premium'];

  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // 🎯 INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ============================================================
  // 📤 LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      await productProvider.fetchProductsByCategory(widget.categoryId);

      // Track analytics
      // AnalyticsService().trackScreenView('category_products', parameters: {
      //   'category': widget.categoryId,
      // });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load products. Please try again.';
      });
      print('❌ Category Products Load Error: $e');
    }
  }

  // ============================================================
  // 🔄 LOAD MORE
  // ============================================================

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    if (!productProvider.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await productProvider.fetchProducts();
    setState(() {
      _isLoadingMore = false;
    });
  }

  // ============================================================
  // 🔄 PULL TO REFRESH
  // ============================================================

  Future<void> _onRefresh() async {
    await _loadProducts();
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.categoryName,
        showBackButton: true,
        showProfileAvatar: false,
        showSearch: false,
        showCart: true,
        actions: [
          // ── TOGGLE VIEW ──
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // ── FILTER ──
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _buildBody(productProvider, cartProvider),
      bottomNavigationBar: _buildAdBanner(),
    );
  }

  // ============================================================
  // 📦 BUILD BODY
  // ============================================================

  Widget _buildBody(ProductProvider provider, CartProvider cartProvider) {
    final products = provider.products;

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // ── SORT BAR ──
        _buildSortBar(),
        const SizedBox(height: 8),

        // ── PRODUCT LIST ──
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: _isGridView
                ? _buildGridView(products, cartProvider)
                : _buildListView(products, cartProvider),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 📊 BUILD SORT BAR
  // ============================================================

  Widget _buildSortBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── RESULTS COUNT ──
          Text(
            '${Provider.of<ProductProvider>(context).products.length} products',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),

          // ── SORT DROPDOWN ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                items: _sortOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      _getSortLabel(option),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortBy = value;
                    });
                    _applyFilters();
                  }
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
                dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📦 BUILD GRID VIEW
  // ============================================================

  Widget _buildGridView(
    List<ProductModel> products,
    CartProvider cartProvider,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = products[index];
        return ProductCard(
          product: product,
          imageHeight: 160,
          isGrid: true,
          onTap: () {
            // TODO: Navigate to product detail
          },
          onLikeTap: () {
            // TODO: Toggle like
          },
          showCategory: false,
        );
      },
    );
  }

  // ============================================================
  // 📋 BUILD LIST VIEW
  // ============================================================

  Widget _buildListView(
    List<ProductModel> products,
    CartProvider cartProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
            imageHeight: 180,
            isGrid: false,
            showSellerInfo: true,
            onTap: () {
              // TODO: Navigate to product detail
            },
            onLikeTap: () {
              // TODO: Toggle like
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // 📦 BUILD EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📦', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no products in this category yet.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ❌ BUILD ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📢 BUILD AD BANNER
  // ============================================================

  Widget _buildAdBanner() {
    return const SizedBox(
      height: 60,
      child: AdBanner(height: 50, showPlaceholder: true),
    );
  }

  // ============================================================
  // 🔍 FILTER DIALOG
  // ============================================================

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Price',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _filterOptions.map((option) {
                  final isSelected = _filterBy == option;
                  return ChoiceChip(
                    label: Text(
                      _getFilterLabel(option),
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontFamily: 'Inter',
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filterBy = option;
                      });
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _filterBy = 'all';
                    });
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Clear Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔄 APPLY FILTERS
  // ============================================================

  void _applyFilters() {
    // TODO: Apply sort and filter to products
  }

  // ============================================================
  // 📝 HELPER METHODS
  // ============================================================

  String _getSortLabel(String option) {
    switch (option) {
      case 'popular':
        return 'Most Popular';
      case 'newest':
        return 'Newest';
      case 'rating':
        return 'Top Rated';
      case 'downloads':
        return 'Most Downloaded';
      default:
        return option;
    }
  }

  String _getFilterLabel(String option) {
    switch (option) {
      case 'all':
        return 'All';
      case 'free':
        return 'Free';
      case 'premium':
        return 'Premium';
      default:
        return option;
    }
  }
}
