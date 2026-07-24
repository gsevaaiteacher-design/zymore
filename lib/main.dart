// ============================================================
// 📁 FILE: main.dart
// 📍 LOCATION: lib/main.dart
// 🎯 PURPOSE: App Entry Point - Zymore Marketplace App
// 🔗 USED BY: Flutter Framework (App Launch)
// 📝 DESCRIPTION: 
//    This file initializes the entire Zymore app.
//    - Sets up Firebase
//    - Configures AdMob
//    - Registers all routes
//    - Sets up providers for state management
//    - Handles app lifecycle
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// 📁 IMPORT CONFIG & PROVIDERS
// ============================================================
import 'config/app_config.dart';
import 'config/firebase_options.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

// ============================================================
// 📊 FIREBASE ANALYTICS INSTANCE
// ============================================================
FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// ============================================================
// 🎯 MAIN FUNCTION - App Entry Point
// ============================================================
void main() async {
  // ✅ Ensure Widgets Binding (Required for async operations)
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ============================================================
    // 🔥 FIREBASE INITIALIZATION
    // ============================================================
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Initialized Successfully!');

    // ============================================================
    // 📥 DOWNLOADER INITIALIZATION
    // ============================================================
    await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: false,
    );
    print('✅ Downloader Initialized Successfully!');

    // ============================================================
    // 📱 ADMOB INITIALIZATION
    // ============================================================
    await MobileAds.instance.initialize();
    print('✅ AdMob Initialized Successfully!');

    // ============================================================
    // 🔔 FIREBASE MESSAGING (Push Notifications)
    // ============================================================
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    
    // Request notification permissions
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification Permissions Granted!');
    } else {
      print('❌ Notification Permissions Denied!');
    }

    // ============================================================
    // 💾 SHARED PREFERENCES (Local Storage)
    // ============================================================
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('✅ Shared Preferences Loaded!');

    // ============================================================
    // 🚀 RUN THE APP
    // ============================================================
    runApp(
      MultiProvider(
        providers: [
          // 🔐 Authentication Provider
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(prefs: prefs),
          ),
          // 📦 Product Provider
          ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider(),
          ),
          // 🎨 Theme Provider
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(prefs: prefs),
          ),
        ],
        child: const ZymoreApp(),
      ),
    );

    print('✅ App Started Successfully!');
  } catch (error) {
    // ============================================================
    // ❌ ERROR HANDLING - If Firebase or other services fail
    // ============================================================
    print('❌ App Initialization Error: $error');
    
    // Run app with minimal configuration to show error
    runApp(
      MaterialApp(
        title: AppConfig.appName,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: 20),
                Text(
                  'App Initialization Failed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please restart the app.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Error: $error',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🏠 ZYMORE APP - Main Widget
// ============================================================
class ZymoreApp extends StatefulWidget {
  const ZymoreApp({super.key});

  @override
  State<ZymoreApp> createState() => _ZymoreAppState();
}

class _ZymoreAppState extends State<ZymoreApp> with WidgetsBindingObserver {
  // ============================================================
  // 🎯 ANALYTICS & LIFE-CYCLE MANAGEMENT
  // ============================================================
  
  @override
  void initState() {
    super.initState();
    
    // 🎯 Add observer for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    // 📊 Track app start in analytics
    _trackAppOpen();
    
    // 🔔 Handle push notifications
    _setupNotificationListeners();
  }

  @override
  void dispose() {
    // 🧹 Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ============================================================
  // 📊 APP LIFECYCLE EVENTS
  // ============================================================
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔄 App Resumed');
        _trackAppEvent('app_resumed');
        break;
      case AppLifecycleState.inactive:
        print('⏸️ App Inactive');
        break;
      case AppLifecycleState.paused:
        print('⏸️ App Paused');
        _trackAppEvent('app_paused');
        break;
      case AppLifecycleState.detached:
        print('❌ App Detached');
        break;
      case AppLifecycleState.hidden:
        print('👁️ App Hidden');
        break;
    }
  }

  // ============================================================
  // 📊 ANALYTICS HELPER METHODS
  // ============================================================
  
  /// Track app open event in Firebase Analytics
  void _trackAppOpen() {
    try {
      analytics.logEvent(
        name: 'app_open',
        parameters: {
          'app_name': AppConfig.appName,
          'app_version': AppConfig.appVersion,
        },
      );
      print('📊 Analytics: App Open Tracked');
    } catch (e) {
      print('❌ Analytics Error: $e');
    }
  }

  /// Track general app events
  void _trackAppEvent(String eventName) {
    try {
      analytics.logEvent(name: eventName);
    } catch (e) {
      // Silent fail for analytics errors
    }
  }

  // ============================================================
  // 🔔 PUSH NOTIFICATION HANDLERS
  // ============================================================
  
  void _setupNotificationListeners() {
    try {
      // Handle when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Foreground Notification: ${message.notification?.title}');
        _trackAppEvent('notification_foreground');
      });

      // Handle when app is in background or terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📩 Notification Clicked: ${message.notification?.title}');
        _trackAppEvent('notification_clicked');
        
        // TODO: Navigate to specific screen based on notification data
      });
    } catch (e) {
      print('❌ Notification Setup Error: $e');
    }
  }

  // ============================================================
  // 🎨 BUILD METHOD - The App UI
  // ============================================================
  
  @override
  Widget build(BuildContext context) {
    // 🎨 Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    // ============================================================
    // 🎯 MATERIAL APP WITH THEME
    // ============================================================
    return MaterialApp(
      // 📱 Basic Configuration
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.showDebugBanner,
      
      // 🎨 Theme Settings
      theme: themeProvider.currentTheme,
      
      // 🌐 Localization
      localizationsDelegates: const [
        // Add your localization delegates here if needed
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        // Add more locales here for multi-language support
      ],
      
      // 🧭 Navigation
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      
      // ⚠️ Unknown Route Handler
      onGenerateRoute: (settings) {
        // If route doesn't exist, go to splash screen
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      },
      
      // 📊 Analytics Observer
      navigatorObservers: [
        // FirebaseAnalyticsObserver(analytics: analytics), // Uncomment when needed
      ],
      
      // 🏠 Home (Fallback)
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING - Simple Test
// ============================================================
/*
 🧪 UNIT TEST FOR main.dart

 void main() {
   test('App Configuration Test', () {
     expect(AppConfig.appName, 'Zymore');
     expect(AppConfig.appVersion, '1.0.0');
   });
 }
*/