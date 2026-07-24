// ============================================================
// 📁 FILE: routes.dart
// 📍 LOCATION: lib/config/routes.dart
// 🎯 PURPOSE: App Route Configuration
// ============================================================

import 'package:flutter/material.dart';

import '../screens/ai_chat_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/category_products.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/image_editor_screen.dart';
import '../screens/product_detail.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/upload_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String upload = '/upload';
  static const String productDetail = '/product-detail';
  static const String categoryProducts = '/category-products';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String history = '/history';
  static const String aiChat = '/ai-chat';
  static const String imageEditor = '/image-editor';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        auth: (_) => const AuthScreen(),
        home: (_) => const HomeScreen(),
        upload: (_) => const UploadScreen(),
        productDetail: (_) => const ProductDetailScreen(),
        categoryProducts: (_) => const CategoryProductsScreen(),
        profile: (_) => const ProfileScreen(),
        settings: (_) => const SettingsScreen(),
        history: (_) => const HistoryScreen(),
        aiChat: (_) => const AiChatScreen(),
        imageEditor: (_) => const ImageEditorScreen(),
      };
}
