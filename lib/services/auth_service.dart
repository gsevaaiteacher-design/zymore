// ============================================================
// 📁 FILE: auth_service.dart
// 📍 LOCATION: lib/services/auth_service.dart
// 🎯 PURPOSE: Authentication Service - Firebase Auth Operations
// 🔗 USED BY: Auth Provider, All Screens
// 📝 DESCRIPTION:
//    This file handles all authentication operations:
//    - Sign in with Google
//    - Sign in with Email/Password
//    - Register with Email/Password
//    - Sign out
//    - Password reset
//    - Email verification
//    - User data management
//    - Session management
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ============================================================
// 📁 IMPORT MODELS & CONSTANTS
// ============================================================
import '../models/user_model.dart';
import '../utils/constants.dart';

// ============================================================
// 🔐 AUTH SERVICE - Singleton
// ============================================================

class AuthService {
  // ── SINGLETON ──
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ── FIREBASE INSTANCES ──
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── STATE ──
  bool _isInitialized = false;
  User? _currentUser;
  UserModel? _currentUserModel;
  StreamSubscription<User?>? _authStateSubscription;

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _authListeners = [];

  // ============================================================
  // 🚀 INITIALIZATION
  // ============================================================

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Listen to auth state changes
      _authStateSubscription = _auth.authStateChanges().listen(
        (User? user) async {
          _currentUser = user;
          if (user != null) {
            _currentUserModel = await _getUserModel(user.uid);
            _emitEvent('auth.state_changed', {
              'uid': user.uid,
              'email': user.email,
              'isAuthenticated': true,
            });
          } else {
            _currentUserModel = null;
            _emitEvent('auth.state_changed', {'isAuthenticated': false});
          }
        },
        onError: (error) {
          print('❌ Auth State Error: $error');
          _emitEvent('auth.state_error', {'error': error.toString()});
        },
      );

      _isInitialized = true;
      _emitEvent('auth.initialized', {});
      print('✅ Auth Service Initialized');
    } catch (e) {
      print('❌ Auth Init Error: $e');
      _emitEvent('auth.init_error', {'error': e.toString()});
    }
  }

  // ============================================================
  // 🔐 AUTHENTICATION METHODS
  // ============================================================

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      _emitEvent('auth.google.start', {});

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _emitEvent('auth.google.cancelled', {});
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

      final User? user = userCredential.user;
      if (user == null) {
        _emitEvent('auth.google.failed', {'error': 'User is null'});
        return null;
      }

      // Save user to Firestore
      final userModel = await _saveUserToFirestore(user);

      // Save to SharedPreferences
      await _saveUserToPrefs(userModel);

      _currentUser = user;
      _currentUserModel = userModel;

      _emitEvent('auth.google.success', {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('❌ Google SignIn Error: ${e.code} - ${e.message}');
      _emitEvent('auth.google.error', {'code': e.code, 'message': e.message});
      return null;
    } catch (e) {
      print('❌ Google SignIn Error: $e');
      _emitEvent('auth.google.error', {'error': e.toString()});
      return null;
    }
  }

  /// Sign in with Email and Password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      _emitEvent('auth.email.start', {'email': email});

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final User? user = userCredential.user;
      if (user == null) {
        _emitEvent('auth.email.failed', {'error': 'User is null'});
        return null;
      }

      // Update last login
      await _updateLastLogin(user.uid);

      final userModel = await _getUserModel(user.uid);
      if (userModel == null) {
        _emitEvent('auth.email.failed', {'error': 'User model not found'});
        return null;
      }

      _currentUser = user;
      _currentUserModel = userModel;

      await _saveUserToPrefs(userModel);

      _emitEvent('auth.email.success', {'uid': user.uid, 'email': user.email});

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('❌ Email SignIn Error: ${e.code} - ${e.message}');
      _emitEvent('auth.email.error', {'code': e.code, 'message': e.message});
      return null;
    } catch (e) {
      print('❌ Email SignIn Error: $e');
      _emitEvent('auth.email.error', {'error': e.toString()});
      return null;
    }
  }

  /// Register with Email and Password
  Future<UserModel?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      _emitEvent('auth.register.start', {'email': email});

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? user = userCredential.user;
      if (user == null) {
        _emitEvent('auth.register.failed', {'error': 'User is null'});
        return null;
      }

      // Update display name
      await user.updateDisplayName(name);
      await user.reload();

      // Save user to Firestore
      final userModel = await _saveUserToFirestore(user, isNewUser: true);

      // Send email verification
      await sendEmailVerification();

      _currentUser = user;
      _currentUserModel = userModel;

      await _saveUserToPrefs(userModel);

      _emitEvent('auth.register.success', {
        'uid': user.uid,
        'email': user.email,
        'displayName': name,
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('❌ Register Error: ${e.code} - ${e.message}');
      _emitEvent('auth.register.error', {'code': e.code, 'message': e.message});
      return null;
    } catch (e) {
      print('❌ Register Error: $e');
      _emitEvent('auth.register.error', {'error': e.toString()});
      return null;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      _emitEvent('auth.signout.start', {});

      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();

      _currentUser = null;
      _currentUserModel = null;

      // Clear preferences
      await _clearUserPrefs();

      _emitEvent('auth.signout.success', {});
      return true;
    } catch (e) {
      print('❌ SignOut Error: $e');
      _emitEvent('auth.signout.error', {'error': e.toString()});
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      _emitEvent('auth.reset.start', {'email': email});

      await _auth.sendPasswordResetEmail(email: email.trim());

      _emitEvent('auth.reset.success', {'email': email});
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Password Reset Error: ${e.code} - ${e.message}');
      _emitEvent('auth.reset.error', {'code': e.code, 'message': e.message});
      return false;
    } catch (e) {
      print('❌ Password Reset Error: $e');
      _emitEvent('auth.reset.error', {'error': e.toString()});
      return false;
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _emitEvent('auth.verify.error', {'error': 'No user logged in'});
        return false;
      }

      await user.sendEmailVerification();
      _emitEvent('auth.verify.sent', {'email': user.email});
      return true;
    } catch (e) {
      print('❌ Email Verification Error: $e');
      _emitEvent('auth.verify.error', {'error': e.toString()});
      return false;
    }
  }

  /// Reload user
  Future<bool> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      _currentUser = _auth.currentUser;
      return true;
    } catch (e) {
      print('❌ Reload User Error: $e');
      return false;
    }
  }

  // ============================================================
  // 💾 USER DATA MANAGEMENT
  // ============================================================

  /// Save user to Firestore
  Future<UserModel> _saveUserToFirestore(
    User user, {
    bool isNewUser = false,
  }) async {
    try {
      final userRef = _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid);
      final doc = await userRef.get();

      if (doc.exists) {
        // Update existing user
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        });
      } else {
        // Create new user
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoURL: user.photoURL ?? '',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isSeller: false,
          isAdmin: false,
        );

        await userRef.set(userModel.toFirestore());
      }

      return await _getUserModel(user.uid) ?? UserModel.fromFirebaseUser(user);
    } catch (e) {
      print('❌ Save User Error: $e');
      return UserModel.fromFirebaseUser(user);
    }
  }

  /// Get user model from Firestore
  Future<UserModel?> _getUserModel(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Get User Model Error: $e');
      return null;
    }
  }

  /// Update user last login
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection(AppConstants.collectionUsers).doc(uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      print('❌ Update Last Login Error: $e');
    }
  }

  // ============================================================
  // 💾 SHARED PREFERENCES
  // ============================================================

  Future<void> _saveUserToPrefs(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefUserId, user.id);
      await prefs.setString(AppConstants.prefUserEmail, user.email);
      await prefs.setString(AppConstants.prefUserName, user.displayName);
      await prefs.setString(AppConstants.prefUserPhoto, user.photoURL);
      await prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await prefs.setBool(AppConstants.prefIsSeller, user.isSeller);
    } catch (e) {
      print('❌ Save User to Prefs Error: $e');
    }
  }

  Future<void> _clearUserPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefUserId);
      await prefs.remove(AppConstants.prefUserEmail);
      await prefs.remove(AppConstants.prefUserName);
      await prefs.remove(AppConstants.prefUserPhoto);
      await prefs.setBool(AppConstants.prefIsLoggedIn, false);
      await prefs.setBool(AppConstants.prefIsSeller, false);
    } catch (e) {
      print('❌ Clear User Prefs Error: $e');
    }
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;
  String get userId => _currentUser?.uid ?? '';
  String get userEmail => _currentUser?.email ?? '';
  String get userName => _currentUser?.displayName ?? '';
  String get userPhoto => _currentUser?.photoURL ?? '';

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitEvent(String eventType, dynamic data) {
    for (var listener in _authListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Auth listener error: $e');
      }
    }
  }

  void addListener(Function(String, dynamic) listener) {
    _authListeners.add(listener);
  }

  void removeListener(Function(String, dynamic) listener) {
    _authListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  void dispose() {
    _authStateSubscription?.cancel();
    _authListeners.clear();
  }
}
