// ============================================================
// 📁 FILE: firebase_options.dart
// 📍 LOCATION: lib/config/firebase_options.dart
// 🎯 PURPOSE: Firebase Configuration Options
// ============================================================

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDummyKeyForBuildCompatibility',
      appId: '1:1234567890:android:abcdef1234567890',
      messagingSenderId: '1234567890',
      projectId: 'zymore-app',
      storageBucket: 'zymore-app.appspot.com',
    );
  }
}
