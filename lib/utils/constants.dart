// ============================================================
// 📁 FILE: constants.dart
// 📍 LOCATION: lib/utils/constants.dart
// 🎯 PURPOSE: App Constants - Centralized App Configuration
// 🔗 USED BY: All Files (Global Access)
// 📝 DESCRIPTION:
//    This file contains all app-wide constants including:
//    - App Name, Version, Branding
//    - Color Scheme (Light & Dark)
//    - Asset Paths
//    - Category Names & IDs
//    - Firebase Collection Names
//    - Ad Unit IDs
//    - API Keys (for future use)
//    - Error Messages
//    - Validation Rules
//    - Shared Preferences Keys
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 🏷️ APP CONSTANTS - Main App Information
// ============================================================

class AppConstants {
  // ============================================================
  // 📱 APP INFO
  // ============================================================
  static const String appName = 'Zymore';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.zymore.app';
  static const String tagline = 'Free Digital Marketplace';
  static const String appDescription =
      'Zymore - India\'s Fastest Growing Digital Marketplace for Creators & Artists. Download high-quality wallpapers, icons, digital art, and assets for free.';

  // ============================================================
  // ⚡ POWERED BY - Brand Credit
  // ============================================================
  static const String poweredBy = 'Zynquar';
  static const String poweredByLink = 'https://zynquar.com'; // Optional
  static const String copyright = '© 2024-2025 Zynquar. All rights reserved.';

  // ============================================================
  // 🎨 COLOR CONSTANTS
  // ============================================================
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color secondaryColor = Color(0xFF1A1A2E);
  static const Color accentColor = Color(0xFF00D4FF);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color textColor = Color(0xFF1A1A2E);
  static const Color textLightColor = Color(0xFF7F8C8D);

  // ============================================================
  // 📁 ASSET PATHS
  // ============================================================
  static const String assetsBase = 'assets/';
  static const String imagesBase = '${assetsBase}images/';
  static const String iconsBase = '${assetsBase}icons/';
  static const String fontsBase = '${assetsBase}fonts/';

  // Images
  static const String logo = '${imagesBase}logo.png';
  static const String splash = '${imagesBase}splash.png';
  static const String banner1 = '${imagesBase}banner1.png';
  static const String banner2 = '${imagesBase}banner2.png';
  static const String banner3 = '${imagesBase}banner3.png';

  // Icons
  static const String icLauncher = '${iconsBase}ic_launcher.png';
  static const String icNotification = '${iconsBase}ic_notification.png';
  static const String icDownload = '${iconsBase}ic_download.png';
  static const String icUpload = '${iconsBase}ic_upload.png';
  static const String googleLogo = '${iconsBase}google_logo.png';

  // Fonts
  static const String poppinsBold = '${fontsBase}Poppins-Bold.ttf';
  static const String interRegular = '${fontsBase}Inter-Regular.ttf';
  static const String interLight = '${fontsBase}Inter-Light.ttf';

  // ============================================================
  // 📊 FIREBASE COLLECTION NAMES
  // ============================================================
  static const String collectionUsers = 'users';
  static const String collectionProducts = 'products';
  static const String collectionReviews = 'reviews';
  static const String collectionDownloads = 'downloads';
  static const String collectionLikes = 'likes';
  static const String collectionCategories = 'categories';

  // ============================================================
  // 🏷️ CATEGORY CONSTANTS
  // ============================================================
  static const List<String> categories = [
    'Wallpaper',
    'Icon',
    'Art',
    'Asset',
  ];

  static const Map<String, String> categoryIcons = {
    'Wallpaper': '🖼️',
    'Icon': '🎯',
    'Art': '🎨',
    'Asset': '📦',
  };

  static const Map<String, Color> categoryColors = {
    'Wallpaper': Color(0xFFFF6B35),
    'Icon': Color(0xFF00D4FF),
    'Art': Color(0xFF9B59B6),
    'Asset': Color(0xFF2ECC71),
  };

  // ============================================================
  // 📝 ERROR MESSAGES
  // ============================================================
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorEmail = 'Invalid email address.';
  static const String errorPassword = 'Password must be at least 6 characters.';
  static const String errorPasswordsMatch = 'Passwords do not match.';
  static const String errorName = 'Name must be at least 2 characters.';
  static const String errorRequired = 'This field is required.';
  static const String errorInvalid = 'Invalid input. Please check again.';
  static const String errorUpload = 'Upload failed. Please try again.';
  static const String errorDownload = 'Download failed. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';

  // ============================================================
  // ✅ SUCCESS MESSAGES
  // ============================================================
  static const String successLogin = 'Login successful! Welcome back!';
  static const String successRegister = 'Registration successful! Welcome!';
  static const String successLogout = 'Logged out successfully.';
  static const String successUpload = 'Product uploaded successfully!';
  static const String successDownload = 'Download completed successfully!';
  static const String successReview = 'Review submitted successfully!';
  static const String successLike = 'Added to your likes!';
  static const String successUnlike = 'Removed from your likes.';
  static const String successPasswordReset = 'Password reset email sent!';

  // ============================================================
  // 🔑 SHARED PREFERENCES KEYS
  // ============================================================
  static const String prefAuthToken = 'auth_token';
  static const String prefUserId = 'user_id';
  static const String prefUserEmail = 'user_email';
  static const String prefUserName = 'user_name';
  static const String prefUserPhoto = 'user_photo';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefIsSeller = 'is_seller';
  static const String prefDarkMode = 'dark_mode';
  static const String prefLanguage = 'language';
  static const String prefNotifications = 'notifications';
  static const String prefFirstTime = 'first_time';

  // ============================================================
  // 📐 VALIDATION CONSTANTS
  // ============================================================
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxTagsLength = 10;
  static const int maxFileSizeMB = 20; // For direct upload
  static const int maxImagesUpload = 5;

  // ============================================================
  // 💰 ADMOB AD UNIT IDs
  // ============================================================
  // 🔴 IMPORTANT: Replace with your actual AdMob IDs
  static const String adBannerId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String adRewardedId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String adInterstitialId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String adNativeId = 'ca-app-pub-3940256099942544/2247696110'; // Test ID

  // ============================================================
  // 🌐 API ENDPOINTS (Future Use)
  // ============================================================
  static const String apiBaseUrl = 'https://api.zymore.com';
  static const String apiAiChat = '${apiBaseUrl}/ai/chat';
  static const String apiImageEditor = '${apiBaseUrl}/ai/edit';
  static const String apiAnalytics = '${apiBaseUrl}/analytics';

  // ============================================================
  // 🎯 ANIMATION DURATIONS
  // ============================================================
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationLong = Duration(milliseconds: 600);
  static const Duration splashDelay = Duration(seconds: 2);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // ============================================================
  // 📱 SCREEN BREAKPOINTS (Responsive)
  // ============================================================
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ============================================================
  // 📦 PADDING & SPACING
  // ============================================================
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // ============================================================
  // 🔘 BUTTON STYLES
  // ============================================================
  static const double buttonHeight = 56.0;
  static const double buttonRadius = 12.0;
  static const double buttonElevation = 3.0;

  // ============================================================
  // 🖼️ IMAGE DIMENSIONS
  // ============================================================
  static const double productThumbnailHeight = 200.0;
  static const double productThumbnailWidth = double.infinity;
  static const double categoryCardHeight = 120.0;
  static const double bannerHeight = 180.0;
  static const double logoSize = 120.0;
  static const double avatarSize = 50.0;
}

// ============================================================
// 🎨 APP COLORS - Extended Color Palette
// ============================================================

class AppColors {
  // ============================================================
  // 🟠 PRIMARY COLORS
  // ============================================================
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryGradientStart = Color(0xFFFF6B35);
  static const Color primaryGradientEnd = Color(0xFFFF9A5C);

  // ============================================================
  // 🔵 SECONDARY COLORS
  // ============================================================
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color secondaryLight = Color(0xFF2A2A4E);
  static const Color secondaryDark = Color(0xFF0A0A1E);

  // ============================================================
  // 🔷 ACCENT COLORS
  // ============================================================
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentLight = Color(0xFF33DDFF);
  static const Color accentDark = Color(0xFF00B5D9);

  // ============================================================
  // ⚪ BACKGROUND COLORS
  // ============================================================
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);

  // ============================================================
  // 🟢 STATUS COLORS
  // ============================================================
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // ============================================================
  // ⚫ TEXT COLORS
  // ============================================================
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A4A5E);
  static const Color textTertiary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textLightSecondary = Color(0xFFB0B0B0);

  // ============================================================
  // 🌟 SHADOW COLORS
  // ============================================================
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // ============================================================
  // 📊 CHART COLORS
  // ============================================================
  static const List<Color> chartColors = [
    Color(0xFFFF6B35),
    Color(0xFF00D4FF),
    Color(0xFF2ECC71),
    Color(0xFFF39C12),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
  ];
}

// ============================================================
// 📦 APP ASSETS - Extended Asset Paths
// ============================================================

class AppAssets {
  // ============================================================
  // 🖼️ IMAGES
  // ============================================================
  static const String logo = 'assets/images/logo.png';
  static const String splash = 'assets/images/splash.png';
  static const String banner1 = 'assets/images/banner1.png';
  static const String banner2 = 'assets/images/banner2.png';
  static const String banner3 = 'assets/images/banner3.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorImage = 'assets/images/error_image.png';

  // ============================================================
  // 🎯 ICONS
  // ============================================================
  static const String icLauncher = 'assets/icons/ic_launcher.png';
  static const String icNotification = 'assets/icons/ic_notification.png';
  static const String icDownload = 'assets/icons/ic_download.png';
  static const String icUpload = 'assets/icons/ic_upload.png';
  static const String googleLogo = 'assets/icons/google_logo.png';
  static const String appleLogo = 'assets/icons/apple_logo.png';
  static const String facebookLogo = 'assets/icons/facebook_logo.png';

  // ============================================================
  // 🔤 FONTS
  // ============================================================
  static const String poppinsBold = 'assets/fonts/Poppins-Bold.ttf';
  static const String poppinsMedium = 'assets/fonts/Poppins-Medium.ttf';
  static const String poppinsRegular = 'assets/fonts/Poppins-Regular.ttf';
  static const String interRegular = 'assets/fonts/Inter-Regular.ttf';
  static const String interLight = 'assets/fonts/Inter-Light.ttf';
  static const String interBold = 'assets/fonts/Inter-Bold.ttf';
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 UNIT TEST FOR constants.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   test('App Constants Test', () {
     // Test App Name
     expect(AppConstants.appName, 'Zymore');
     
     // Test Version
     expect(AppConstants.appVersion, '1.0.0');
     
     // Test Powered By
     expect(AppConstants.poweredBy, 'Zynquar');
     
     // Test Categories
     expect(AppConstants.categories.length, 4);
     expect(AppConstants.categories.contains('Wallpaper'), true);
     
     // Test Colors
     expect(AppColors.primary, const Color(0xFFFF6B35));
     expect(AppColors.success, const Color(0xFF2ECC71));
   });
 }
*/