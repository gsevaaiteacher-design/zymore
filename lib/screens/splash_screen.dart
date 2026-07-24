// ============================================================
// 📁 FILE: splash_screen.dart
// 📍 LOCATION: lib/screens/splash_screen.dart
// 🎯 PURPOSE: Splash Screen - App Launch Screen
// 🔗 USED BY: main.dart (Initial Route)
// 📝 DESCRIPTION:
//    This file displays the splash screen with:
//    - App logo with animation
//    - App name and tagline
//    - Authentication status check
//    - Navigation to Home or Auth screen
//    - Powered By footer
//    - Error handling with retry
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// ============================================================
// 📁 IMPORT PROVIDERS & SCREENS
// ============================================================
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

// ============================================================
// 🎯 SPLASH SCREEN - Stateful Widget
// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // 📊 STATE VARIABLES
  // ============================================================

  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // ============================================================
  // 🔄 INIT STATE - Called when widget is created
  // ============================================================

  @override
  void initState() {
    super.initState();

    // 🎨 Initialize animations
    _initAnimations();

    // 🚀 Start the splash screen process
    _startSplashScreen();
  }

  // ============================================================
  // 🧹 DISPOSE - Clean up resources
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🎨 INITIALIZE ANIMATIONS
  // ============================================================

  void _initAnimations() {
    // Animation Controller - Duration 2 seconds
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade Animation - 0.0 to 1.0
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Scale Animation - 0.8 to 1.0
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  // ============================================================
  // 🚀 START SPLASH SCREEN PROCESS
  // ============================================================

  Future<void> _startSplashScreen() async {
    try {
      // ⏳ Wait for animation to complete (minimum 2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      // 🔐 Check if user is already logged in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      // ✅ Navigate based on auth status
      if (authProvider.isAuthenticated) {
        // User is logged in - Go to Home
        _navigateToHome();
      } else {
        // User is NOT logged in - Go to Auth
        _navigateToAuth();
      }
    } catch (error) {
      // ❌ Error occurred - Show error message
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please restart the app.';
      });
      print('❌ Splash Screen Error: $error');
    }
  }

  // ============================================================
  // 🧭 NAVIGATION METHODS
  // ============================================================

  /// Navigate to Home Screen with fade transition
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  /// Navigate to Auth Screen with fade transition
  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ============================================================
  // 🎨 RETRY BUTTON - When error occurs
  // ============================================================

  void _retrySplash() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _startSplashScreen();
  }

  // ============================================================
  // 🎨 BUILD METHOD - UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // 🎨 Get theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      // 🖼️ Status Bar Style
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      // 📦 Body
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.secondary,
                    AppColors.secondary.withOpacity(0.8),
                    AppColors.primary,
                  ]
                : [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primary.withOpacity(0.7),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingContent()
              : _buildErrorContent(),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 BUILD LOADING CONTENT
  // ============================================================

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🖼️ App Logo with Animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    AppAssets.logo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 🔄 Fallback if image not found
                      return Icon(
                        Icons.shopping_bag,
                        size: 60,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 📱 App Name
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 📝 Tagline
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              AppConstants.tagline,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 50),

          // ⏳ Loading Indicator
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),

          // ============================================================
          // ⚡ POWERED BY SECTION (Footer)
          // ============================================================
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Divider Line
                Container(
                  width: 100,
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                
                // "Powered By" Text
                Text(
                  '⚡ Powered By',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Inter',
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Brand Name - Zynquar
                Text(
                  AppConstants.poweredBy,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Version Info
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.3),
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
  // 🎨 BUILD ERROR CONTENT
  // ============================================================

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ❌ Error Icon
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),

            // ❌ Error Message
            Text(
              'Oops! Something Went Wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              _errorMessage ?? 'Please try again.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 🔄 Retry Button
            ElevatedButton(
              onPressed: _retrySplash,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 18,
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
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 UNIT TEST FOR splash_screen.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:provider/provider.dart';

 void main() {
   testWidgets('Splash screen displays logo', (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: ChangeNotifierProvider(
           create: (_) => AuthProvider(),
           child: const SplashScreen(),
         ),
       ),
     );

     // Wait for splash screen
     await tester.pumpAndSettle();

     // Verify app name is displayed
     expect(find.text('Zymore'), findsOneWidget);
   });

   testWidgets('Splash screen shows loading indicator',
       (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: ChangeNotifierProvider(
           create: (_) => AuthProvider(),
           child: const SplashScreen(),
         ),
       ),
     );

     // Verify loading indicator is displayed
     expect(find.byType(CircularProgressIndicator), findsOneWidget);
   });
 }
*/

// ============================================================
// 📊 ANALYTICS - Track Splash Screen
// ============================================================

/*
 📊 ANALYTICS TRACKING

 // Track when splash screen is shown
 analytics.logEvent(
   name: 'splash_screen_view',
   parameters: {
     'timestamp': DateTime.now().toString(),
   },
 );

 // Track navigation from splash
 analytics.logEvent(
   name: 'splash_navigation',
   parameters: {
     'destination': isLoggedIn ? 'home' : 'auth',
   },
 );
*/