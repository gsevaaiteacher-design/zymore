// ============================================================
// 📁 FILE: analytics_service.dart
// 📍 LOCATION: lib/services/analytics_service.dart
// 🎯 PURPOSE: Analytics Service - User & App Analytics
// 🔗 USED BY: All Providers, Services, Screens
// 📝 DESCRIPTION:
//    This file handles all analytics tracking:
//    - Firebase Analytics
//    - Screen tracking
//    - User events
//    - Custom events
//    - User properties
//    - Error tracking
//    - Performance metrics
//    - Session management
//    - Engagement metrics
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ============================================================
// 📊 ANALYTICS SERVICE - Singleton
// ============================================================

class AnalyticsService {
  // ── SINGLETON ──
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // ── FIREBASE ANALYTICS ──
  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  // ── STATE ──
  String _currentScreen = '';
  DateTime? _sessionStartTime;
  int _sessionCount = 0;
  bool _isInitialized = false;
  bool _isEnabled = true;

  // ── USER PROPERTIES ──
  String? _userId;
  String? _userEmail;
  bool _isAuthenticated = false;

  // ── CACHE ──
  final Map<String, dynamic> _eventCache = {};
  final List<Map<String, dynamic>> _pendingEvents = [];

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _analyticsListeners = [];

  // ============================================================
  // 🚀 INITIALIZATION
  // ============================================================

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Get Firebase Analytics instance
      _analytics = FirebaseAnalytics.instance;

      // Create observer
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // Set default user properties
      await _setDefaultProperties();

      // Track session start
      _sessionStartTime = DateTime.now();
      await _getSessionCount();

      _isInitialized = true;

      _emitEvent('analytics.initialized', {
        'sessionCount': _sessionCount,
        'enabled': _isEnabled,
      });

      print('✅ Analytics Service Initialized');
    } catch (e) {
      print('❌ Analytics Init Error: $e');
      _isEnabled = false;
      _emitEvent('analytics.init.error', {'error': e.toString()});
    }
  }

  // ============================================================
  // 📊 SCREEN TRACKING
  // ============================================================

  /// Track screen view
  Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      _currentScreen = screenName;

      await _analytics!.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenClass,
      );

      // Track screen view event
      await _logEvent(
        'screen_view',
        parameters: {
          'screen_name': screenName,
          'screen_class': screenClass ?? screenName,
          'session_count': _sessionCount,
          ...?parameters,
        },
      );

      _emitEvent('analytics.screen_view', {
        'screen': screenName,
        'parameters': parameters,
      });
    } catch (e) {
      print('❌ Track Screen View Error: $e');
    }
  }

  // ============================================================
  // 🎯 USER EVENTS
  // ============================================================

  /// Track user login
  Future<void> trackLogin(String method) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      _isAuthenticated = true;
      _userId = _auth.currentUser?.uid;
      _userEmail = _auth.currentUser?.email;

      await _setUserProperties();

      await _logEvent(
        'login',
        parameters: {'method': method, 'user_id': _userId},
      );

      _emitEvent('analytics.login', {'method': method, 'userId': _userId});
    } catch (e) {
      print('❌ Track Login Error: $e');
    }
  }

  /// Track user logout
  Future<void> trackLogout() async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'logout',
        parameters: {
          'user_id': _userId,
          'session_duration': _getSessionDuration(),
        },
      );

      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;

      _emitEvent('analytics.logout', {});
    } catch (e) {
      print('❌ Track Logout Error: $e');
    }
  }

  /// Track user registration
  Future<void> trackRegistration(String method) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'sign_up',
        parameters: {'method': method, 'user_id': _userId},
      );

      _emitEvent('analytics.registration', {'method': method});
    } catch (e) {
      print('❌ Track Registration Error: $e');
    }
  }

  // ============================================================
  // 🛒 PRODUCT EVENTS
  // ============================================================

  /// Track product view
  Future<void> trackProductView(
    String productId,
    String productName,
    String category,
  ) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'view_item',
        parameters: {
          'item_id': productId,
          'item_name': productName,
          'item_category': category,
        },
      );

      _emitEvent('analytics.product_view', {
        'productId': productId,
        'productName': productName,
      });
    } catch (e) {
      print('❌ Track Product View Error: $e');
    }
  }

  /// Track product download
  Future<void> trackProductDownload(
    String productId,
    String productName,
    String category,
  ) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'download',
        parameters: {
          'item_id': productId,
          'item_name': productName,
          'item_category': category,
        },
      );

      _emitEvent('analytics.product_download', {
        'productId': productId,
        'productName': productName,
      });
    } catch (e) {
      print('❌ Track Product Download Error: $e');
    }
  }

  /// Track product like
  Future<void> trackProductLike(
    String productId,
    String productName,
    bool liked,
  ) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        liked ? 'like' : 'unlike',
        parameters: {'item_id': productId, 'item_name': productName},
      );

      _emitEvent('analytics.product_like', {
        'productId': productId,
        'liked': liked,
      });
    } catch (e) {
      print('❌ Track Product Like Error: $e');
    }
  }

  /// Track product share
  Future<void> trackProductShare(
    String productId,
    String productName,
    String method,
  ) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'share',
        parameters: {
          'item_id': productId,
          'item_name': productName,
          'method': method,
        },
      );

      _emitEvent('analytics.product_share', {
        'productId': productId,
        'method': method,
      });
    } catch (e) {
      print('❌ Track Product Share Error: $e');
    }
  }

  /// Track product upload (Seller)
  Future<void> trackProductUpload(
    String productId,
    String productName,
    String category,
  ) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'upload_product',
        parameters: {
          'item_id': productId,
          'item_name': productName,
          'item_category': category,
        },
      );

      _emitEvent('analytics.product_upload', {
        'productId': productId,
        'productName': productName,
      });
    } catch (e) {
      print('❌ Track Product Upload Error: $e');
    }
  }

  // ============================================================
  // 💰 AD EVENTS
  // ============================================================

  /// Track ad impression
  Future<void> trackAdImpression(String adType, String adUnitId) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'ad_impression',
        parameters: {'ad_type': adType, 'ad_unit_id': adUnitId},
      );

      _emitEvent('analytics.ad_impression', {'adType': adType});
    } catch (e) {
      print('❌ Track Ad Impression Error: $e');
    }
  }

  /// Track ad click
  Future<void> trackAdClick(String adType, String adUnitId) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'ad_click',
        parameters: {'ad_type': adType, 'ad_unit_id': adUnitId},
      );

      _emitEvent('analytics.ad_click', {'adType': adType});
    } catch (e) {
      print('❌ Track Ad Click Error: $e');
    }
  }

  /// Track ad reward earned
  Future<void> trackAdReward(
    String adType,
    double rewardAmount,
    String rewardType,
  ) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'ad_reward_earned',
        parameters: {
          'ad_type': adType,
          'reward_amount': rewardAmount,
          'reward_type': rewardType,
        },
      );

      _emitEvent('analytics.ad_reward', {
        'adType': adType,
        'rewardAmount': rewardAmount,
      });
    } catch (e) {
      print('❌ Track Ad Reward Error: $e');
    }
  }

  // ============================================================
  // 👤 USER PROPERTIES
  // ============================================================

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      _userId = userId;

      _emitEvent('analytics.user_id_set', {'userId': userId});
    } catch (e) {
      print('❌ Set User ID Error: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty(String key, String value) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: key, value: value);

      _emitEvent('analytics.user_property_set', {'key': key, 'value': value});
    } catch (e) {
      print('❌ Set User Property Error: $e');
    }
  }

  /// Set user properties from auth
  Future<void> _setUserProperties() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await setUserId(user.uid);
    await setUserProperty('email', user.email ?? '');
    await setUserProperty('display_name', user.displayName ?? '');
  }

  /// Set default properties
  Future<void> _setDefaultProperties() async {
    if (_analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: 'app_version', value: '1.0.0');
      await _analytics!.setUserProperty(
        name: 'platform',
        value: Platform.isAndroid ? 'android' : 'ios',
      );
    } catch (e) {
      print('❌ Set Default Properties Error: $e');
    }
  }

  // ============================================================
  // 🔧 CUSTOM EVENTS
  // ============================================================

  /// Log custom event
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(eventName, parameters: parameters);

      _emitEvent('analytics.custom_event', {
        'event': eventName,
        'parameters': parameters,
      });
    } catch (e) {
      print('❌ Log Custom Event Error: $e');
    }
  }

  /// Internal log event
  Future<void> _logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Clean parameters (remove null values)
      final cleanParams = <String, dynamic>{};
      if (parameters != null) {
        for (var entry in parameters.entries) {
          if (entry.value != null) {
            cleanParams[entry.key] = entry.value;
          }
        }
      }

      await _analytics!.logEvent(name: eventName, parameters: cleanParams);
    } catch (e) {
      print('❌ Log Event Error: $e');
    }
  }

  // ============================================================
  // 🏥 ERROR TRACKING
  // ============================================================

  /// Track error
  Future<void> trackError(
    String error, {
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'app_error',
        parameters: {
          'error': error,
          'stack_trace': stackTrace,
          'screen': _currentScreen,
          ...?context,
        },
      );

      _emitEvent('analytics.error', {'error': error, 'context': context});
    } catch (e) {
      print('❌ Track Error Error: $e');
    }
  }

  /// Track API error
  Future<void> trackApiError(
    String endpoint,
    String error, {
    int? statusCode,
  }) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'api_error',
        parameters: {
          'endpoint': endpoint,
          'error': error,
          'status_code': statusCode,
          'screen': _currentScreen,
        },
      );

      _emitEvent('analytics.api_error', {
        'endpoint': endpoint,
        'error': error,
        'statusCode': statusCode,
      });
    } catch (e) {
      print('❌ Track API Error Error: $e');
    }
  }

  // ============================================================
  // 📊 PERFORMANCE METRICS
  // ============================================================

  /// Track page load time
  Future<void> trackPageLoadTime(String page, Duration duration) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'page_load_time',
        parameters: {'page': page, 'load_time_ms': duration.inMilliseconds},
      );
    } catch (e) {
      print('❌ Track Page Load Time Error: $e');
    }
  }

  /// Track app launch
  Future<void> trackAppLaunch() async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _logEvent(
        'app_launch',
        parameters: {
          'session_count': _sessionCount,
          'is_first_launch': _sessionCount == 1,
        },
      );
    } catch (e) {
      print('❌ Track App Launch Error: $e');
    }
  }

  // ============================================================
  // 📈 SESSION MANAGEMENT
  // ============================================================

  Future<void> _getSessionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionCount = prefs.getInt('session_count') ?? 0;
      _sessionCount++;
      await prefs.setInt('session_count', _sessionCount);
    } catch (e) {
      print('❌ Get Session Count Error: $e');
    }
  }

  String _getSessionDuration() {
    if (_sessionStartTime == null) return '0';
    final duration = DateTime.now().difference(_sessionStartTime!);
    return duration.inSeconds.toString();
  }

  // ============================================================
  // 🛠️ UTILITY METHODS
  // ============================================================

  /// Get analytics observer for navigation
  FirebaseAnalyticsObserver? get observer => _observer;

  /// Get Firebase Analytics instance
  FirebaseAnalytics? get analytics => _analytics;

  /// Enable/disable analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    _emitEvent('analytics.enabled_changed', {'enabled': enabled});
  }

  /// Reset analytics
  Future<void> reset() async {
    try {
      await _analytics?.resetAnalyticsData();
      _emitEvent('analytics.reset', {});
    } catch (e) {
      print('❌ Reset Analytics Error: $e');
    }
  }

  // ============================================================
  // 📊 GET STATS
  // ============================================================

  Map<String, dynamic> getStats() {
    return {
      'isInitialized': _isInitialized,
      'isEnabled': _isEnabled,
      'sessionCount': _sessionCount,
      'currentScreen': _currentScreen,
      'isAuthenticated': _isAuthenticated,
      'userId': _userId,
      'pendingEvents': _pendingEvents.length,
      'cacheSize': _eventCache.length,
    };
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitEvent(String eventType, dynamic data) {
    for (var listener in _analyticsListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Analytics listener error: $e');
      }
    }
  }

  void addListener(Function(String, dynamic) listener) {
    _analyticsListeners.add(listener);
  }

  void removeListener(Function(String, dynamic) listener) {
    _analyticsListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  void dispose() {
    _analyticsListeners.clear();
    _eventCache.clear();
    _pendingEvents.clear();
  }
}
