// ============================================================
// 📁 FILE: auth_provider.dart
// 📍 LOCATION: lib/providers/auth_provider.dart
// 🎯 PURPOSE: Authentication State Management Provider
// 🔗 USED BY: All Screens (Auth, Splash, Home, Profile)
// 📝 DESCRIPTION:
//    This file manages authentication state using Provider:
//    - User authentication status
//    - Login/Register with Email/Password
//    - Google Sign In
//    - Logout
//    - Password Reset
//    - User data persistence
//    - Auto-login on app restart
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ============================================================
// 📁 IMPORT MODELS & SERVICES
// ============================================================
import '../models/user_model.dart';
import '../utils/constants.dart';

// ============================================================
// 🎯 AUTH PROVIDER - State Management
// ============================================================

class AuthProvider extends ChangeNotifier {
  // ── SINGLETON ──
  static AuthProvider? _instance;
  static AuthProvider get instance {
    _instance ??= AuthProvider();
    return _instance!;
  }

  // ── DEPENDENCIES ──
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;

  // ── STATE ──
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _authListeners = [];

  // ── CONSTRUCTOR ──
  AuthProvider({SharedPreferences? prefs})
    : _prefs = prefs ?? (throw Exception('SharedPreferences required')) {
    _initAuth();
  }

  // ── INIT AUTH ──
  Future<void> _initAuth() async {
    try {
      // Check if user is already logged in
      final user = _auth.currentUser;
      if (user != null) {
        _user = await _getUserData(user);
        _isAuthenticated = true;
        _emitAuthEvent('auth.init', {'status': 'authenticated'});
      } else {
        _isAuthenticated = false;
        _emitAuthEvent('auth.init', {'status': 'unauthenticated'});
      }
      notifyListeners();
    } catch (e) {
      print('❌ Auth Init Error: $e');
      _errorMessage = 'Failed to initialize authentication';
      _emitAuthEvent('auth.init.error', {'error': e.toString()});
    }
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String get userId => _user?.id ?? '';
  String get userEmail => _user?.email ?? '';
  String get userName => _user?.displayName ?? '';
  String get userPhoto => _user?.photoURL ?? '';
  bool get isSeller => _user?.isSeller ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  // ============================================================
  // 🔐 AUTHENTICATION METHODS
  // ============================================================

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        _setLoading(false);
        _setError('Google Sign In failed');
        return null;
      }

      // Save user data
      _user = await _saveUserData(firebaseUser);
      _isAuthenticated = true;

      _emitAuthEvent('auth.google_signin', {
        'userId': _user!.id,
        'email': _user!.email,
      });

      _setLoading(false);
      notifyListeners();
      return _user;
    } catch (e) {
      print('❌ Google Sign In Error: $e');
      _setError('Google Sign In failed. Please try again.');
      _setLoading(false);
      _emitAuthEvent('auth.google_signin.error', {'error': e.toString()});
      return null;
    }
  }

  /// Sign in with Email and Password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _setLoading(false);
        _setError('Login failed');
        return null;
      }

      _user = await _saveUserData(firebaseUser);
      _isAuthenticated = true;

      _emitAuthEvent('auth.email_signin', {
        'userId': _user!.id,
        'email': _user!.email,
      });

      _setLoading(false);
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print('❌ Email SignIn Error: ${e.code}');
      _setError(_getFirebaseErrorMessage(e));
      _setLoading(false);
      _emitAuthEvent('auth.email_signin.error', {'error': e.code});
      return null;
    } catch (e) {
      print('❌ Email SignIn Error: $e');
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return null;
    }
  }

  /// Register with Email and Password
  Future<UserModel?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _setLoading(false);
        _setError('Registration failed');
        return null;
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();

      _user = await _saveUserData(firebaseUser, isNewUser: true);
      _isAuthenticated = true;

      _emitAuthEvent('auth.register', {
        'userId': _user!.id,
        'email': _user!.email,
        'name': name,
      });

      _setLoading(false);
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print('❌ Register Error: ${e.code}');
      _setError(_getFirebaseErrorMessage(e));
      _setLoading(false);
      _emitAuthEvent('auth.register.error', {'error': e.code});
      return null;
    } catch (e) {
      print('❌ Register Error: $e');
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return null;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    _setLoading(true);

    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();

      // Clear user data
      _user = null;
      _isAuthenticated = false;

      // Clear preferences
      await _clearUserPreferences();

      _emitAuthEvent('auth.signout', {});

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ SignOut Error: $e');
      _setError('Sign out failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      _emitAuthEvent('auth.password_reset', {'email': email});

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Password Reset Error: ${e.code}');
      _setError(_getFirebaseErrorMessage(e));
      _setLoading(false);
      _emitAuthEvent('auth.password_reset.error', {'error': e.code});
      return false;
    } catch (e) {
      print('❌ Password Reset Error: $e');
      _setError('Failed to send reset email. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _user = await _getUserData(user);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _user = null;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Check Auth Status Error: $e');
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // 💾 USER DATA MANAGEMENT
  // ============================================================

  /// Save user data to Firestore and SharedPreferences
  Future<UserModel> _saveUserData(User user, {bool isNewUser = false}) async {
    final UserModel userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      isSeller: false,
      isAdmin: false,
    );

    // Save to SharedPreferences
    await _saveUserPreferences(userModel);

    // TODO: Save to Firestore (will be implemented in database_service)

    return userModel;
  }

  /// Get user data from Firebase
  Future<UserModel> _getUserData(User user) async {
    // Try to load from SharedPreferences first
    final cachedUser = await _getUserPreferences();
    if (cachedUser != null && cachedUser.id == user.uid) {
      return cachedUser;
    }

    // Create from Firebase user
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      isSeller: false,
      isAdmin: false,
    );
  }

  // ============================================================
  // 💾 SHARED PREFERENCES
  // ============================================================

  Future<void> _saveUserPreferences(UserModel user) async {
    try {
      await _prefs.setString(AppConstants.prefUserId, user.id);
      await _prefs.setString(AppConstants.prefUserEmail, user.email);
      await _prefs.setString(AppConstants.prefUserName, user.displayName);
      await _prefs.setString(AppConstants.prefUserPhoto, user.photoURL);
      await _prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await _prefs.setBool(AppConstants.prefIsSeller, user.isSeller);
    } catch (e) {
      print('❌ Save Preferences Error: $e');
    }
  }

  Future<UserModel?> _getUserPreferences() async {
    try {
      final isLoggedIn = _prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
      if (!isLoggedIn) return null;

      final userId = _prefs.getString(AppConstants.prefUserId) ?? '';
      if (userId.isEmpty) return null;

      return UserModel(
        id: userId,
        email: _prefs.getString(AppConstants.prefUserEmail) ?? '',
        displayName: _prefs.getString(AppConstants.prefUserName) ?? '',
        photoURL: _prefs.getString(AppConstants.prefUserPhoto) ?? '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isSeller: _prefs.getBool(AppConstants.prefIsSeller) ?? false,
        isAdmin: false,
      );
    } catch (e) {
      print('❌ Get Preferences Error: $e');
      return null;
    }
  }

  Future<void> _clearUserPreferences() async {
    try {
      await _prefs.remove(AppConstants.prefUserId);
      await _prefs.remove(AppConstants.prefUserEmail);
      await _prefs.remove(AppConstants.prefUserName);
      await _prefs.remove(AppConstants.prefUserPhoto);
      await _prefs.setBool(AppConstants.prefIsLoggedIn, false);
      await _prefs.setBool(AppConstants.prefIsSeller, false);
    } catch (e) {
      print('❌ Clear Preferences Error: $e');
    }
  }

  // ============================================================
  // 📝 ERROR HANDLING
  // ============================================================

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/Password sign in is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _emitAuthEvent('auth.error', {'message': message});
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitAuthEvent(String eventType, dynamic data) {
    for (var listener in _authListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Auth listener error: $e');
      }
    }
  }

  void addAuthListener(Function(String, dynamic) listener) {
    _authListeners.add(listener);
  }

  void removeAuthListener(Function(String, dynamic) listener) {
    _authListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  @override
  void dispose() {
    _authListeners.clear();
    super.dispose();
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR auth_provider.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:shared_preferences/shared_preferences.dart';

 void main() {
   test('AuthProvider initializes correctly', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = AuthProvider(prefs: prefs);
     expect(provider.isAuthenticated, false);
     expect(provider.isLoading, false);
     expect(provider.user, null);
   });

   test('AuthProvider getters return correct values', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = AuthProvider(prefs: prefs);
     expect(provider.userId, '');
     expect(provider.userEmail, '');
     expect(provider.userName, '');
     expect(provider.userPhoto, '');
     expect(provider.isSeller, false);
     expect(provider.isAdmin, false);
   });

   test('AuthProvider error handling works', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = AuthProvider(prefs: prefs);
     provider._setError('Test error');
     expect(provider.errorMessage, 'Test error');
     
     provider._clearError();
     expect(provider.errorMessage, null);
   });
 }
*/
