// ============================================================
// 📁 FILE: home_screen.dart
// 📍 LOCATION: lib/screens/home_screen.dart
// 🎯 PURPOSE: Home Screen - Main Dashboard
// 🔗 USED BY: main.dart (After Login)
// 📝 DESCRIPTION:
//    This is the main home screen with:
//    - App bar with search and profile
//    - Banner slider (marketing)
//    - Categories grid
//    - Featured products
//    - Recent uploads
//    - Bottom navigation
//    - Pull to refresh
//    - Loading states
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
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// 📁 IMPORT MODELS, PROVIDERS, WIDGETS, UTILS
// ============================================================
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';
import '../widgets/banner_slider.dart';
import '../widgets/ad_banner.dart';
import '../widgets/loading_indicator.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// ── SCREENS ──
import 'category_products.dart';
import 'profile_screen.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

// ============================================================
// 🏠 HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // ── STATE ──
  int _selectedIndex = 0;
  final RefreshController _refreshController = RefreshController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  // ── NAVIGATION ITEMS ──
  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.upload_file_outlined),
      activeIcon: Icon(Icons.upload_file),
      label: 'Upload',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: 'History',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  // ============================================================
  // 🎯 INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // 📤 LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load products
      await productProvider.fetchProducts(refresh: true);

      // Load user products if seller
      if (authProvider.isSeller) {
        await productProvider.fetchUserProducts();
      }

      // Track analytics
      // AnalyticsService().trackScreenView('home');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data. Please try again.';
      });
      print('❌ Home Screen Load Error: $e');
    }
  }

  // ============================================================
  // 🔄 PULL TO REFRESH
  // ============================================================

  Future<void> _onRefresh() async {
    await _loadData();
    _refreshController.refreshCompleted();
  }

  // ============================================================
  // 🧭 NAVIGATION
  // ============================================================

  void _onNavItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - do nothing
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadScreen()),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        subtitle:
            'Welcome, ${authProvider.userName.isNotEmpty ? authProvider.userName : 'Guest'}',
        showProfileAvatar: true,
        showSearch: true,
        showCart: true,
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        onSearchPressed: () {
          // TODO: Open search screen
        },
        onCartPressed: () {
          // TODO: Open cart screen
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildBody(productProvider),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ============================================================
  // 📦 BUILD BODY
  // ============================================================

  Widget _buildBody(ProductProvider productProvider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BANNER SLIDER ──
          _buildBannerSlider(),
          const SizedBox(height: 16),

          // ── AD BANNER ──
          _buildAdBanner(),
          const SizedBox(height: 16),

          // ── CATEGORIES ──
          _buildCategories(),
          const SizedBox(height: 20),

          // ── FEATURED PRODUCTS ──
          _buildFeaturedProducts(productProvider),
          const SizedBox(height: 16),

          // ── RECENT UPLOADS ──
          _buildRecentUploads(productProvider),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼️ BUILD BANNER SLIDER
  // ============================================================

  Widget _buildBannerSlider() {
    final banners = [
      BannerModel(
        id: 'banner_1',
        imageUrl:
            'https://via.placeholder.com/800x400/FF6B35/FFFFFF?text=Zymore',
        title: 'Welcome to Zymore',
        subtitle: 'Discover amazing digital products',
        buttonText: 'Explore Now',
        overlayColor: Colors.black.withOpacity(0.4),
      ),
      BannerModel(
        id: 'banner_2',
        imageUrl:
            'https://via.placeholder.com/800x400/00D4FF/FFFFFF?text=Digital+Assets',
        title: 'Digital Assets',
        subtitle: 'High quality digital assets for your projects',
        buttonText: 'View Assets',
        overlayColor: Colors.black.withOpacity(0.4),
      ),
      BannerModel(
        id: 'banner_3',
        imageUrl:
            'https://via.placeholder.com/800x400/2ECC71/FFFFFF?text=Wallpapers',
        title: 'Beautiful Wallpapers',
        subtitle: 'HD wallpapers for your device',
        buttonText: 'Download Now',
        overlayColor: Colors.black.withOpacity(0.4),
      ),
    ];

    return BannerSlider(
      banners: banners,
      height: 180,
      showIndicators: true,
      showTitle: true,
      showSubtitle: true,
      showButton: false,
    );
  }

  // ============================================================
  // 📢 BUILD AD BANNER
  // ============================================================

  Widget _buildAdBanner() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AdBanner(height: 60, showPlaceholder: true),
    );
  }

  // ============================================================
  // 🏷️ BUILD CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    final categories = CategoryModel.getPresetCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show all categories
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CategoryCardList(
          categories: categories,
          onCategoryTap: (category) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // ⭐ BUILD FEATURED PRODUCTS
  // ============================================================

  Widget _buildFeaturedProducts(ProductProvider provider) {
    final products = provider.allProducts;
    final featured = products.take(10).toList();

    if (featured.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show all products
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ProductCardList(
          products: featured,
          imageHeight: 180,
          itemWidth: 160,
          onProductTap: (product) {
            // TODO: Navigate to product detail
          },
          onLikeTap: (product) {
            // TODO: Toggle like
          },
        ),
      ],
    );
  }

  // ============================================================
  // 📤 BUILD RECENT UPLOADS
  // ============================================================

  Widget _buildRecentUploads(ProductProvider provider) {
    final products = provider.allProducts;
    final recent = products.take(10).toList();

    if (recent.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Uploads',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show all products
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ProductCardList(
          products: recent,
          imageHeight: 180,
          itemWidth: 160,
          onProductTap: (product) {
            // TODO: Navigate to product detail
          },
          onLikeTap: (product) {
            // TODO: Toggle like
          },
        ),
      ],
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
              onPressed: _loadData,
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
  // 📱 BUILD BOTTOM NAV
  // ============================================================

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTap,
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey[500],
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}

// ============================================================
// 🔄 REFRESH CONTROLLER (Custom)
// ============================================================

class RefreshController {
  bool _isRefreshing = false;

  void refreshCompleted() {
    _isRefreshing = false;
  }

  void refreshFailed() {
    _isRefreshing = false;
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR home_screen.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:provider/provider.dart';

 void main() {
   testWidgets('HomeScreen displays correctly', 
       (WidgetTester tester) async {
     // Mock providers
     await tester.pumpWidget(
       MaterialApp(
         home: MultiProvider(
           providers: [
             ChangeNotifierProvider(create: (_) => AuthProvider()),
             ChangeNotifierProvider(create: (_) => ProductProvider()),
             ChangeNotifierProvider(create: (_) => CartProvider()),
             ChangeNotifierProvider(create: (_) => ThemeProvider()),
           ],
           child: const HomeScreen(),
         ),
       ),
     );

     expect(find.text('Zymore'), findsOneWidget);
     expect(find.byType(CategoryCardList), findsOneWidget);
   });
 }
*/
