// ============================================================
// 📁 FILE: banner_slider.dart
// 📍 LOCATION: lib/widgets/banner_slider.dart
// 🎯 PURPOSE: Marketing Banner Slider Widget
// 🔗 USED BY: Home Screen
// 📝 DESCRIPTION:
//    This widget displays a carousel of marketing banners:
//    - Auto-play carousel
//    - Page indicator dots
//    - Banner images with overlay text
//    - Click handler for each banner
//    - Gradient overlays
//    - Responsive design
//    - Loading shimmer effect
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// ============================================================
// 📁 IMPORT UTILS
// ============================================================
import '../utils/constants.dart';

// ============================================================
// 📊 BANNER MODEL
// ============================================================

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? buttonText;
  final Color? overlayColor;
  final VoidCallback? onTap;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.subtitle = '',
    this.buttonText,
    this.overlayColor,
    this.onTap,
  });
}

// ============================================================
// 🎯 BANNER SLIDER
// ============================================================

class BannerSlider extends StatefulWidget {
  // ── PROPERTIES ──
  final List<BannerModel> banners;
  final double height;
  final double viewportFraction;
  final Duration autoPlayDuration;
  final bool showIndicators;
  final bool showTitle;
  final bool showSubtitle;
  final bool showButton;
  final bool enableAutoPlay;
  final double borderRadius;

  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 180,
    this.viewportFraction = 0.9,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.showIndicators = true,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showButton = false,
    this.enableAutoPlay = true,
    this.borderRadius = 16,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.banners.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // ── CAROUSEL ──
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: widget.viewportFraction,
            autoPlay: widget.enableAutoPlay && widget.banners.length > 1,
            autoPlayInterval: widget.autoPlayDuration,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.banners.map((banner) {
            return _buildBannerItem(context, banner);
          }).toList(),
        ),
        const SizedBox(height: 12),

        // ── INDICATORS ──
        if (widget.showIndicators && widget.banners.length > 1)
          _buildIndicators(),
      ],
    );
  }

  // ============================================================
  // 🎨 BUILD BANNER ITEM
  // ============================================================

  Widget _buildBannerItem(BuildContext context, BannerModel banner) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: banner.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── IMAGE ──
              CachedNetworkImage(
                imageUrl: banner.imageUrl,
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

              // ── OVERLAY ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      banner.overlayColor ?? Colors.black.withOpacity(0.6),
                      banner.overlayColor?.withOpacity(0.2) ??
                          Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ── CONTENT ──
              _buildContent(context, banner),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📝 BUILD CONTENT
  // ============================================================

  Widget _buildContent(BuildContext context, BannerModel banner) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TITLE ──
          if (widget.showTitle && banner.title.isNotEmpty)
            Text(
              banner.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 4),

          // ── SUBTITLE ──
          if (widget.showSubtitle && banner.subtitle.isNotEmpty)
            Text(
              banner.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Inter',
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          // ── BUTTON ──
          if (widget.showButton && banner.buttonText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  banner.buttonText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔵 BUILD INDICATORS
  // ============================================================

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        return Container(
          width: _currentIndex == entry.key ? 24 : 8,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: _currentIndex == entry.key
                ? AppColors.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }).toList(),
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
        height: widget.height,
      ),
    );
  }
}

// ============================================================
// 📋 BANNER SLIDER SKELETON
// ============================================================

class BannerSliderSkeleton extends StatelessWidget {
  final double height;
  final double borderRadius;

  const BannerSliderSkeleton({
    super.key,
    this.height = 180,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ============================================================
// 📊 SAMPLE BANNERS
// ============================================================

class SampleBanners {
  static List<BannerModel> getDefaultBanners() {
    return [
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
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR banner_slider.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   testWidgets('BannerSlider displays banners correctly',
       (WidgetTester tester) async {
     final banners = SampleBanners.getDefaultBanners();

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: BannerSlider(banners: banners),
         ),
       ),
     );

     expect(find.text('Welcome to Zymore'), findsOneWidget);
     expect(find.text('Discover amazing digital products'), findsOneWidget);
     expect(find.text('Explore Now'), findsOneWidget);
   });

   testWidgets('BannerSlider shows indicators when enabled',
       (WidgetTester tester) async {
     final banners = SampleBanners.getDefaultBanners();

     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: BannerSlider(
             banners: banners,
             showIndicators: true,
           ),
         ),
       ),
     );

     // Verify indicators are present
     expect(find.byType(Row), findsWidgets);
   });

   testWidgets('BannerSlider handles empty banners gracefully',
       (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           body: const BannerSlider(banners: []),
         ),
       ),
     );

     // Should render without error
     expect(find.byType(SizedBox), findsOneWidget);
   });
 }
*/
