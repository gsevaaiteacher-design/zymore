// ============================================================
// 📁 FILE: category_card.dart
// 📍 LOCATION: lib/widgets/category_card.dart
// 🎯 PURPOSE: Category Card Widget
// 🔗 USED BY: Home Screen, Category Screen
// 📝 DESCRIPTION:
//    This widget displays a category card with:
//    - Category icon/emoji
//    - Category name
//    - Product count
//    - Gradient background
//    - Click handler
//    - Loading shimmer effect
//    - Responsive design
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ============================================================
// 📁 IMPORT MODELS & UTILS
// ============================================================
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// ============================================================
// 🎯 CATEGORY CARD
// ============================================================

class CategoryCard extends StatelessWidget {
  // ── PROPERTIES ──
  final CategoryModel category;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double borderRadius;
  final bool showProductCount;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.width = 100,
    this.height = 100,
    this.borderRadius = 16,
    this.showProductCount = true,
    this.isSelected = false,
  });

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = category.colorValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [color, color.withOpacity(0.8)]
                : [
                    color.withOpacity(isDark ? 0.3 : 0.15),
                    color.withOpacity(isDark ? 0.15 : 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(isDark ? 0.2 : 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── ICON ──
            _buildIcon(context, color),
            const SizedBox(height: 8),

            // ── NAME ──
            _buildName(context, isDark),
            const SizedBox(height: 2),

            // ── PRODUCT COUNT ──
            if (showProductCount) _buildProductCount(context, isDark),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎯 BUILD ICON
  // ============================================================

  Widget _buildIcon(BuildContext context, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(category.icon, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  // ============================================================
  // 📝 BUILD NAME
  // ============================================================

  Widget _buildName(BuildContext context, bool isDark) {
    return Text(
      category.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? category.colorValue
            : (isDark ? Colors.white : AppColors.textPrimary),
        fontFamily: 'Poppins',
      ),
    );
  }

  // ============================================================
  // 📊 BUILD PRODUCT COUNT
  // ============================================================

  Widget _buildProductCount(BuildContext context, bool isDark) {
    return Text(
      category.productCountDisplay,
      style: TextStyle(
        fontSize: 10,
        color: isDark ? Colors.white38 : Colors.grey[500],
        fontFamily: 'Inter',
      ),
    );
  }
}

// ============================================================
// 📋 CATEGORY CARD LIST (Horizontal Scroll)
// ============================================================

class CategoryCardList extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;
  final String? selectedCategoryId;
  final double cardWidth;
  final double cardHeight;

  const CategoryCardList({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.selectedCategoryId,
    this.cardWidth = 100,
    this.cardHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CategoryCard(
              category: category,
              width: cardWidth,
              height: cardHeight,
              isSelected: isSelected,
              onTap: () => onCategoryTap?.call(category),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// 📋 CATEGORY CARD GRID
// ============================================================

class CategoryCardGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;
  final String? selectedCategoryId;
  final int crossAxisCount;
  final double cardWidth;
  final double cardHeight;

  const CategoryCardGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.selectedCategoryId,
    this.crossAxisCount = 4,
    this.cardWidth = 80,
    this.cardHeight = 90,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: cardWidth / cardHeight,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        return CategoryCard(
          category: category,
          width: cardWidth,
          height: cardHeight,
          isSelected: isSelected,
          onTap: () => onCategoryTap?.call(category),
          showProductCount: true,
        );
      },
    );
  }
}

// ============================================================
// ✨ CATEGORY CARD SKELETON (Loading State)
// ============================================================

class CategoryCardSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CategoryCardSkeleton({
    super.key,
    this.width = 100,
    this.height = 100,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 60, height: 12, color: Colors.grey),
            const SizedBox(height: 4),
            Container(width: 40, height: 10, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🏷️ CATEGORY CHIP (Small Tag)
// ============================================================

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showIcon;

  const CategoryChip({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = category.colorValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Text(category.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.textPrimary),
                fontFamily: 'Inter',
              ),
            ),
            if (category.productCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '(${category.productCount})',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : (isDark ? Colors.white38 : Colors.grey[500]),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR category_card.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   testWidgets('CategoryCard displays category info correctly',
       (WidgetTester tester) async {
     final category = CategoryModel(
       id: 'wallpaper',
       name: 'Wallpaper',
       icon: '🖼️',
       color: '#FF6B35',
       productCount: 50,
     );

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: CategoryCard(category: category),
         ),
       ),
     );

     expect(find.text('Wallpaper'), findsOneWidget);
     expect(find.text('🖼️'), findsOneWidget);
     expect(find.text('50 products'), findsOneWidget);
   });

   testWidgets('CategoryCard shows selected state correctly',
       (WidgetTester tester) async {
     final category = CategoryModel(
       id: 'wallpaper',
       name: 'Wallpaper',
       icon: '🖼️',
       color: '#FF6B35',
     );

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: CategoryCard(category: category, isSelected: true),
         ),
       ),
     );

     // Verify selected state (border and color changes)
     expect(find.text('Wallpaper'), findsOneWidget);
   });

   testWidgets('CategoryChip displays correctly',
       (WidgetTester tester) async {
     final category = CategoryModel(
       id: 'wallpaper',
       name: 'Wallpaper',
       icon: '🖼️',
       color: '#FF6B35',
       productCount: 10,
     );

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: CategoryChip(category: category),
         ),
       ),
     );

     expect(find.text('Wallpaper'), findsOneWidget);
     expect(find.text('(10)'), findsOneWidget);
   });
 }
*/
