// ============================================================
// 📁 FILE: product_card.dart
// 📍 LOCATION: lib/widgets/product_card.dart
// 🎯 PURPOSE: Product Card Widget - Grid/List Display
// 🔗 USED BY: Home Screen, Category Products, Search Results
// 📝 DESCRIPTION:
//    This widget displays a product card with:
//    - Product thumbnail image
//    - Product title
//    - Category tag
//    - Rating stars
//    - Like button
//    - Download count
//    - Price (if any)
//    - Seller info
//    - Shimmer loading effect
//    - Click handler
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// ============================================================
// 📁 IMPORT MODELS, PROVIDERS & UTILS
// ============================================================
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'rating_stars.dart';
import 'loading_indicator.dart';

// ============================================================
// 🎯 PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  // ── PROPERTIES ──
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final bool showSellerInfo;
  final bool showDownloadCount;
  final bool showLikeButton;
  final bool showCategory;
  final bool showPrice;
  final double imageHeight;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isGrid;
  final bool isLiked;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onLikeTap,
    this.showSellerInfo = false,
    this.showDownloadCount = true,
    this.showLikeButton = true,
    this.showCategory = true,
    this.showPrice = false,
    this.imageHeight = 160,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(8),
    this.isGrid = true,
    this.isLiked = false,
  });

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInCart = cartProvider.isInCart(product.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE ──
            _buildImage(context),
            const SizedBox(height: 10),

            // ── CONTENT ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── CATEGORY & LIKE ──
                    _buildHeader(context),
                    const SizedBox(height: 4),

                    // ── TITLE ──
                    _buildTitle(context),
                    const SizedBox(height: 4),

                    // ── RATING ──
                    _buildRating(context),
                    const SizedBox(height: 4),

                    // ── SELLER INFO ──
                    if (showSellerInfo) _buildSellerInfo(context),
                    if (showSellerInfo) const SizedBox(height: 4),

                    // ── DOWNLOADS & PRICE ──
                    _buildFooter(context, authProvider),
                  ],
                ),
              ),
            ),

            // ── CART BUTTON ──
            if (isInCart)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'In Cart',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🖼️ BUILD IMAGE
  // ============================================================

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius - 4),
      child: SizedBox(
        width: double.infinity,
        height: imageHeight,
        child: CachedNetworkImage(
          imageUrl: product.thumbnail,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmer(),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ✨ BUILD SHIMMER
  // ============================================================

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: imageHeight,
      ),
    );
  }

  // ============================================================
  // 🏷️ BUILD HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // ── CATEGORY ──
        if (showCategory)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.categoryEmoji,
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 2),
                Text(
                  product.categoryDisplayName,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // ── LIKE BUTTON ──
        if (showLikeButton)
          GestureDetector(
            onTap: onLikeTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isLiked ? Colors.red : Colors.grey[400],
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // 📝 BUILD TITLE
  // ============================================================

  Widget _buildTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      product.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
    );
  }

  // ============================================================
  // ⭐ BUILD RATING
  // ============================================================

  Widget _buildRating(BuildContext context) {
    if (product.ratingCount == 0) {
      return Text(
        'No ratings',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[400],
          fontFamily: 'Inter',
        ),
      );
    }

    return Row(
      children: [
        RatingStars(rating: product.rating, size: 12, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          '(${product.ratingCount})',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 👤 BUILD SELLER INFO
  // ============================================================

  Widget _buildSellerInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundImage: product.sellerPhoto.isNotEmpty
              ? NetworkImage(product.sellerPhoto)
              : null,
          backgroundColor: AppColors.primary,
          child: product.sellerPhoto.isEmpty
              ? Text(
                  product.sellerName.isNotEmpty
                      ? product.sellerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            product.sellerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 📊 BUILD FOOTER
  // ============================================================

  Widget _buildFooter(BuildContext context, AuthProvider authProvider) {
    return Row(
      children: [
        // ── DOWNLOADS ──
        if (showDownloadCount)
          Row(
            children: [
              Icon(Icons.download, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 2),
              Text(
                product.downloads > 0 ? '${product.downloads}' : '0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),

        const Spacer(),

        // ── VIEWS ──
        if (authProvider.isAuthenticated &&
            authProvider.userId == product.sellerId)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility, size: 12, color: Colors.blue[400]),
                const SizedBox(width: 2),
                Text(
                  '${product.privateViews}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[400],
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================
// 📦 PRODUCT CARD SKELETON (Loading State)
// ============================================================

class ProductCardSkeleton extends StatelessWidget {
  final double imageHeight;
  final double borderRadius;

  const ProductCardSkeleton({
    super.key,
    this.imageHeight = 160,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(borderRadius - 4),
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 12, width: 60, color: Colors.grey[300]),
            const SizedBox(height: 6),
            Container(
              height: 16,
              width: double.infinity,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Container(height: 16, width: 100, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(height: 12, width: 40, color: Colors.grey[300]),
                const Spacer(),
                Container(height: 12, width: 40, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 📋 PRODUCT CARD LIST (Horizontal Scroll)
// ============================================================

class ProductCardList extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onLikeTap;
  final double imageHeight;
  final double itemWidth;

  const ProductCardList({
    super.key,
    required this.products,
    this.onProductTap,
    this.onLikeTap,
    this.imageHeight = 180,
    this.itemWidth = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageHeight + 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.only(right: 12),
            child: ProductCard(
              product: product,
              imageHeight: imageHeight,
              onTap: () => onProductTap?.call(product),
              onLikeTap: () => onLikeTap?.call(product),
              showSellerInfo: true,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// 📋 PRODUCT CARD GRID (Vertical Grid)
// ============================================================

class ProductCardGrid extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onProductTap;
  final Function(ProductModel)? onLikeTap;
  final int crossAxisCount;
  final double imageHeight;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ProductCardGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onLikeTap,
    this.crossAxisCount = 2,
    this.imageHeight = 160,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          imageHeight: imageHeight,
          onTap: () => onProductTap?.call(product),
          onLikeTap: () => onLikeTap?.call(product),
          showSellerInfo: false,
          isGrid: true,
        );
      },
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR product_card.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:provider/provider.dart';

 void main() {
   testWidgets('ProductCard displays product info correctly',
       (WidgetTester tester) async {
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       thumbnail: 'https://example.com/image.jpg',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       downloads: 100,
       likes: 50,
       rating: 4.5,
       ratingCount: 20,
     );

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: ProductCard(product: product),
         ),
       ),
     );

     expect(find.text('Test Product'), findsOneWidget);
     expect(find.text('Wallpaper'), findsOneWidget);
     expect(find.text('100'), findsOneWidget);
   });

   testWidgets('ProductCard shows likes correctly',
       (WidgetTester tester) async {
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       thumbnail: 'https://example.com/image.jpg',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       likes: 50,
     );

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: ProductCard(product: product),
         ),
       ),
     );

     expect(find.byIcon(Icons.favorite_border), findsOneWidget);
   });
 }
*/
