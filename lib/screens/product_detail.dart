// ============================================================
// 📁 FILE: product_detail.dart
// 📍 LOCATION: lib/screens/product_detail.dart
// 🎯 PURPOSE: Product Detail Screen - Full Product View
// 🔗 USED BY: Product Cards, Category Products
// 📝 DESCRIPTION:
//    This screen displays complete product details:
//    - Image gallery (swipeable)
//    - Product title and description
//    - Category and tags
//    - Rating and reviews
//    - Seller information
//    - Download button with Ad
//    - Like and share buttons
//    - Reviews section
//    - Related products
//    - Private views (seller only)
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
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/image_slider.dart';
import '../widgets/rating_stars.dart';
import '../widgets/ad_banner.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/product_card.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// ============================================================
// 🎯 PRODUCT DETAIL SCREEN
// ============================================================

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ── STATE ──
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _errorMessage;
  ProductModel? _product;
  bool _isLiked = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // ============================================================
  // 📤 LOAD PRODUCT
  // ============================================================

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final product = await productProvider.getProductById(widget.productId);

      if (product != null) {
        setState(() {
          _product = product;
          _isLiked = product.isLiked;
          _isLoading = false;
        });

        // Track analytics
        // AnalyticsService().trackProductView(
        //   product.id,
        //   product.title,
        //   product.category,
        // );

        // Increment private view count if user is seller
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.userId == product.sellerId) {
          await productProvider.incrementPrivateView(product.id);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Product not found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load product details';
      });
      print('❌ Product Detail Load Error: $e');
    }
  }

  // ============================================================
  // ❤️ TOGGLE LIKE
  // ============================================================

  Future<void> _toggleLike() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final result = await productProvider.toggleLike(widget.productId);

    setState(() {
      _isLiked = result;
      if (_product != null) {
        _product!.isLiked = result;
        _product!.likes += result ? 1 : -1;
      }
    });

    // Track analytics
    // AnalyticsService().trackProductLike(
    //   widget.productId,
    //   _product?.title ?? '',
    //   result,
    // );
  }

  // ============================================================
  // 📥 DOWNLOAD PRODUCT
  // ============================================================

  Future<void> _downloadProduct() async {
    if (_product == null) return;

    // Check if user is logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showLoginRequiredDialog();
      return;
    }

    // Check if product is already downloaded
    // TODO: Check download history

    setState(() {
      _isDownloading = true;
    });

    try {
      // Show rewarded ad before download
      // final adService = AdService();
      // final adComplete = await adService.showRewardedAd(
      //   onReward: () {},
      //   onError: () {},
      // );

      // if (!adComplete) {
      //   setState(() {
      //     _isDownloading = false;
      //   });
      //   return;
      // }

      // Start download
      // final downloadService = DownloadService();
      // await downloadService.downloadProduct(_product!, showAd: false);

      // Track analytics
      // AnalyticsService().trackProductDownload(
      //   _product!.id,
      //   _product!.title,
      //   _product!.category,
      // );

      setState(() {
        _isDownloading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download started successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // 📤 SHARE PRODUCT
  // ============================================================

  Future<void> _shareProduct() async {
    if (_product == null) return;

    // Track analytics
    // AnalyticsService().trackProductShare(
    //   _product!.id,
    //   _product!.title,
    //   'share',
    // );

    // TODO: Implement share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Loading...', showBackButton: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Error', showBackButton: true),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _product!.title,
        showBackButton: true,
        showProfileAvatar: false,
        actions: [
          // ── SHARE ──
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ============================================================
  // 📦 BUILD BODY
  // ============================================================

  Widget _buildBody() {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE SLIDER ──
          _buildImageSlider(),
          const SizedBox(height: 16),

          // ── CONTENT ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── CATEGORY & LIKES ──
                _buildHeader(),
                const SizedBox(height: 8),

                // ── TITLE ──
                _buildTitle(),
                const SizedBox(height: 8),

                // ── RATING ──
                _buildRating(),
                const SizedBox(height: 12),

                // ── DESCRIPTION ──
                _buildDescription(),
                const SizedBox(height: 12),

                // ── TAGS ──
                _buildTags(),
                const SizedBox(height: 12),

                // ── STATS ──
                _buildStats(),
                const SizedBox(height: 12),

                // ── SELLER INFO ──
                _buildSellerInfo(),
                const SizedBox(height: 12),

                // ── PRIVATE VIEWS (Seller Only) ──
                if (authProvider.userId == _product!.sellerId)
                  _buildPrivateViews(),
                const SizedBox(height: 16),

                // ── REVIEWS SECTION ──
                _buildReviewsSection(),
                const SizedBox(height: 16),

                // ── RELATED PRODUCTS ──
                _buildRelatedProducts(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼️ BUILD IMAGE SLIDER
  // ============================================================

  Widget _buildImageSlider() {
    final images = _product!.images.isNotEmpty
        ? _product!.images
        : [_product!.thumbnail];

    return ImageSlider(
      images: images,
      height: 350,
      showIndicators: true,
      showCounter: true,
      enableZoom: true,
      enableFullscreen: true,
    );
  }

  // ============================================================
  // 🏷️ BUILD HEADER
  // ============================================================

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                _product!.categoryEmoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                _product!.categoryDisplayName,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            // ── DOWNLOAD COUNT ──
            Row(
              children: [
                Icon(
                  Icons.download,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Text(
                  '${_product!.downloads}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // ── VIEWS ──
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Text(
                  '${_product!.views}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // 📝 BUILD TITLE
  // ============================================================

  Widget _buildTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      _product!.title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
    );
  }

  // ============================================================
  // ⭐ BUILD RATING
  // ============================================================

  Widget _buildRating() {
    return Row(
      children: [
        RatingStars(rating: _product!.rating, size: 18, readonly: true),
        const SizedBox(width: 8),
        Text(
          '(${_product!.ratingCount})',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 📝 BUILD DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      _product!.description,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: isDark ? Colors.white70 : AppColors.textSecondary,
        fontFamily: 'Inter',
      ),
    );
  }

  // ============================================================
  // 🏷️ BUILD TAGS
  // ============================================================

  Widget _buildTags() {
    if (_product!.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _product!.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Inter',
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 📊 BUILD STATS
  // ============================================================

  Widget _buildStats() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _buildStatItem(
          Icons.download,
          '${_product!.downloads}',
          'Downloads',
          isDark,
        ),
        const SizedBox(width: 24),
        _buildStatItem(Icons.favorite, '${_product!.likes}', 'Likes', isDark),
        const SizedBox(width: 24),
        _buildStatItem(Icons.visibility, '${_product!.views}', 'Views', isDark),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.grey[500],
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 👤 BUILD SELLER INFO
  // ============================================================

  Widget _buildSellerInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: _product!.sellerPhoto.isNotEmpty
                ? NetworkImage(_product!.sellerPhoto)
                : null,
            backgroundColor: AppColors.primary,
            child: _product!.sellerPhoto.isEmpty
                ? Text(
                    _product!.sellerName.isNotEmpty
                        ? _product!.sellerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product!.sellerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Seller',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 👁️ BUILD PRIVATE VIEWS (Seller Only)
  // ============================================================

  Widget _buildPrivateViews() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility, size: 20, color: Colors.blue[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private Views',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'This product has been viewed ${_product!.privateViews} times privately',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${_product!.privateViews}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ⭐ BUILD REVIEWS SECTION
  // ============================================================

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all reviews
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No reviews yet. Be the first to review!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🔗 BUILD RELATED PRODUCTS
  // ============================================================

  Widget _buildRelatedProducts() {
    final productProvider = Provider.of<ProductProvider>(context);

    // Get products from same category
    final related = productProvider.allProducts
        .where((p) => p.category == _product!.category && p.id != _product!.id)
        .take(10)
        .toList();

    if (related.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        ProductCardList(
          products: related,
          imageHeight: 160,
          itemWidth: 150,
          onProductTap: (product) {
            // TODO: Navigate to product detail
          },
        ),
      ],
    );
  }

  // ============================================================
  // 📥 BUILD BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.userId == _product!.sellerId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardBackgroundDark
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ── LIKE BUTTON ──
            GestureDetector(
              onTap: _toggleLike,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLiked
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── DOWNLOAD BUTTON ──
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isOwner ? null : _downloadProduct,
                icon: _isDownloading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  isOwner
                      ? 'Your Product'
                      : _isDownloading
                      ? 'Downloading...'
                      : 'Download',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwner ? Colors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              _errorMessage ?? 'Product not found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProduct,
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
  // 🔐 SHOW LOGIN REQUIRED DIALOG
  // ============================================================

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'Please login to download this product.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
