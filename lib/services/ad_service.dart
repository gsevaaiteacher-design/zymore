// ============================================================
// 📁 FILE: ad_service.dart
// 📍 LOCATION: lib/services/ad_service.dart
// 🎯 PURPOSE: Ad Service - Google AdMob Integration
// 🔗 USED BY: Download Service, Home Screen, Banner Widgets
// 📝 DESCRIPTION:
//    This file handles all AdMob operations:
//    - Rewarded Ads (Watch to download)
//    - Banner Ads
//    - Interstitial Ads
//    - Native Ads
//    - Ad loading and caching
//    - Ad lifecycle management
//    - Reward handling
//    - Ad unit configuration
//    
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

// ============================================================
// 📁 IMPORT CONSTANTS
// ============================================================
import '../utils/constants.dart';

// ============================================================
// 📊 AD SERVICE - Singleton
// ============================================================

class AdService {
  // ── SINGLETON ──
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ── STATE ──
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  NativeAd? _nativeAd;

  bool _isRewardedLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isBannerLoaded = false;
  bool _isNativeLoaded = false;

  // ── CONFIG ──
  bool _isEnabled = true;
  bool _isTestMode = true; // Set to false for production

  // ── CACHE ──
  final Map<String, dynamic> _adCache = {};
  final List<String> _adHistory = [];

  // ── COMPLETION CALLBACKS ──
  Function? _rewardCallback;
  Function? _rewardErrorCallback;

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _adListeners = [];

  // ── MAX RETRIES ──
  static const int _maxRetries = 3;
  int _retryCount = 0;

  // ============================================================
  // 🚀 INITIALIZATION
  // ============================================================

  Future<void> init({bool testMode = true}) async {
    try {
      _isTestMode = testMode;
      _isEnabled = true;

      // Initialize Mobile Ads SDK
      await MobileAds.instance.initialize();

      // Load initial ads
      await _loadRewardedAd();
      await _loadInterstitialAd();

      _emitEvent('ad.initialized', {
        'testMode': testMode,
        'enabled': true,
      });

      print('✅ Ad Service Initialized');
    } catch (e) {
      print('❌ Ad Service Init Error: $e');
      _isEnabled = false;
      _emitEvent('ad.init.error', {'error': e.toString()});
    }
  }

  // ============================================================
  // 🏆 REWARDED ADS
  // ============================================================

  /// Load a rewarded ad
  Future<bool> _loadRewardedAd() async {
    if (!_isEnabled) return false;

    try {
      // Dispose existing ad
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isRewardedLoaded = false;

      final adUnitId = _isTestMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
          : AppConstants.adRewardedId;

      final rewardedAd = RewardedAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedLoaded = true;
            _retryCount = 0;
            
            // Set event listeners
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _emitEvent('ad.rewarded.dismissed', {});
                _rewardedAd = null;
                _isRewardedLoaded = false;
                _loadRewardedAd(); // Load next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _emitEvent('ad.rewarded.show.error', {'error': error.toString()});
                ad.dispose();
                _rewardedAd = null;
                _isRewardedLoaded = false;
                _loadRewardedAd(); // Retry
              },
            );

            _emitEvent('ad.rewarded.loaded', {});
            print('✅ Rewarded Ad Loaded');
          },
          onAdFailedToLoad: (error) {
            _isRewardedLoaded = false;
            _retryCount++;
            
            if (_retryCount < _maxRetries) {
              _emitEvent('ad.rewarded.load.retry', {
                'retry': _retryCount,
                'error': error.toString(),
              });
              // Retry after delay
              Future.delayed(const Duration(seconds: 5), _loadRewardedAd);
            } else {
              _emitEvent('ad.rewarded.load.error', {'error': error.toString()});
              print('❌ Rewarded Ad Load Error: $error');
            }
          },
        ),
      );

      rewardedAd.load();
      return true;
    } catch (e) {
      print('❌ Load Rewarded Ad Error: $e');
      return false;
    }
  }

  /// Show rewarded ad
  Future<bool> showRewardedAd({
    required Function onReward,
    Function? onError,
  }) async {
    if (!_isEnabled) {
      _emitEvent('ad.rewarded.not.enabled', {});
      onError?.call();
      return false;
    }

    if (_rewardedAd == null || !_isRewardedLoaded) {
      _emitEvent('ad.rewarded.not.loaded', {});
      
      // Try to load first
      await _loadRewardedAd();
      
      if (!_isRewardedLoaded) {
        onError?.call();
        return false;
      }
    }

    _rewardCallback = onReward;
    _rewardErrorCallback = onError;

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          _emitEvent('ad.rewarded.earned', {
            'amount': reward.amount,
            'type': reward.type,
          });
          _rewardCallback?.call();
        },
      );
      return true;
    } catch (e) {
      print('❌ Show Rewarded Ad Error: $e');
      _emitEvent('ad.rewarded.show.error', {'error': e.toString()});
      onError?.call();
      return false;
    }
  }

  // ============================================================
  // 🖼️ BANNER ADS
  // ============================================================

  /// Load a banner ad
  Future<bool> loadBannerAd({
    required double width,
    required Function onLoaded,
    required Function onError,
  }) async {
    if (!_isEnabled) return false;

    try {
      // Dispose existing banner
      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerLoaded = false;

      final adUnitId = _isTestMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
          : AppConstants.adBannerId;

      final bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.getAnchoredAdaptiveBannerAdSize(
          width.floor(),
          Orientation.portrait,
        ),
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAd = ad as BannerAd;
            _isBannerLoaded = true;
            _emitEvent('ad.banner.loaded', {});
            onLoaded();
            print('✅ Banner Ad Loaded');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            _isBannerLoaded = false;
            _emitEvent('ad.banner.load.error', {'error': error.toString()});
            onError();
            print('❌ Banner Ad Load Error: $error');
          },
          onAdOpened: (ad) {
            _emitEvent('ad.banner.opened', {});
          },
          onAdClosed: (ad) {
            _emitEvent('ad.banner.closed', {});
          },
        ),
      );

      bannerAd.load();
      return true;
    } catch (e) {
      print('❌ Load Banner Ad Error: $e');
      onError();
      return false;
    }
  }

  /// Get banner ad widget
  Widget? getBannerWidget({double? width}) {
    if (_bannerAd == null || !_isBannerLoaded) return null;

    return Container(
      width: width ?? double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  // ============================================================
  // 🚀 INTERSTITIAL ADS
  // ============================================================

  /// Load an interstitial ad
  Future<bool> _loadInterstitialAd() async {
    if (!_isEnabled) return false;

    try {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialLoaded = false;

      final adUnitId = _isTestMode
          ? 'ca-app-pub-3940256099942544/1033173712' // Test ID
          : AppConstants.adInterstitialId;

      final interstitialAd = InterstitialAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        listener: InterstitialAdListener(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoaded = true;
            _emitEvent('ad.interstitial.loaded', {});
            print('✅ Interstitial Ad Loaded');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _interstitialAd = null;
            _isInterstitialLoaded = false;
            _emitEvent('ad.interstitial.load.error', {'error': error.toString()});
            print('❌ Interstitial Ad Load Error: $error');
          },
          onAdDismissedFullScreenContent: (ad) {
            _emitEvent('ad.interstitial.dismissed', {});
            _interstitialAd = null;
            _isInterstitialLoaded = false;
            _loadInterstitialAd(); // Load next
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _emitEvent('ad.interstitial.show.error', {'error': error.toString()});
            ad.dispose();
            _interstitialAd = null;
            _isInterstitialLoaded = false;
          },
        ),
      );

      interstitialAd.load();
      return true;
    } catch (e) {
      print('❌ Load Interstitial Ad Error: $e');
      return false;
    }
  }

  /// Show interstitial ad
  Future<bool> showInterstitialAd() async {
    if (!_isEnabled) return false;

    if (_interstitialAd == null || !_isInterstitialLoaded) {
      await _loadInterstitialAd();
      if (!_isInterstitialLoaded) return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      print('❌ Show Interstitial Ad Error: $e');
      return false;
    }
  }

  // ============================================================
  // 📦 NATIVE ADS
  // ============================================================

  /// Load a native ad
  Future<bool> loadNativeAd({
    required Function onLoaded,
    required Function onError,
  }) async {
    if (!_isEnabled) return false;

    try {
      _nativeAd?.dispose();
      _nativeAd = null;
      _isNativeLoaded = false;

      final adUnitId = _isTestMode
          ? 'ca-app-pub-3940256099942544/2247696110' // Test ID
          : AppConstants.adNativeId;

      final nativeAd = NativeAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _nativeAd = ad as NativeAd;
            _isNativeLoaded = true;
            _emitEvent('ad.native.loaded', {});
            onLoaded();
            print('✅ Native Ad Loaded');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _nativeAd = null;
            _isNativeLoaded = false;
            _emitEvent('ad.native.load.error', {'error': error.toString()});
            onError();
            print('❌ Native Ad Load Error: $error');
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor: Colors.white,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.blue,
            backgroundColor: Colors.transparent,
            style: NativeTemplateTextStyle.button,
            size: 16.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black87,
            backgroundColor: Colors.transparent,
            style: NativeTemplateTextStyle.title,
            size: 18.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black54,
            backgroundColor: Colors.transparent,
            style: NativeTemplateTextStyle.body,
            size: 14.0,
          ),
        ),
      );

      nativeAd.load();
      return true;
    } catch (e) {
      print('❌ Load Native Ad Error: $e');
      onError();
      return false;
    }
  }

  /// Get native ad widget
  Widget? getNativeWidget() {
    if (_nativeAd == null || !_isNativeLoaded) return null;

    return Container(
      margin: const EdgeInsets.all(8),
      child: AdWidget(ad: _nativeAd!),
    );
  }

  // ============================================================
  // 🎯 AD UTILITY
  // ============================================================

  /// Check if rewarded ad is available
  bool get isRewardedAvailable => _isRewardedLoaded && _rewardedAd != null;

  /// Check if banner is available
  bool get isBannerAvailable => _isBannerLoaded && _bannerAd != null;

  /// Check if interstitial is available
  bool get isInterstitialAvailable => _isInterstitialLoaded && _interstitialAd != null;

  /// Check if native is available
  bool get isNativeAvailable => _isNativeLoaded && _nativeAd != null;

  /// Enable/disable ads
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    _emitEvent('ad.enabled.changed', {'enabled': enabled});
  }

  /// Set test mode
  void setTestMode(bool testMode) {
    _isTestMode = testMode;
    _emitEvent('ad.testmode.changed', {'testMode': testMode});
  }

  /// Clear all ads
  void clearAds() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _nativeAd?.dispose();

    _rewardedAd = null;
    _bannerAd = null;
    _interstitialAd = null;
    _nativeAd = null;

    _isRewardedLoaded = false;
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
    _isNativeLoaded = false;

    _emitEvent('ad.cleared', {});
  }

  // ============================================================
  // 📊 AD STATS
  // ============================================================

  Map<String, dynamic> getStats() {
    return {
      'rewarded': {
        'loaded': _isRewardedLoaded,
        'available': isRewardedAvailable,
      },
      'banner': {
        'loaded': _isBannerLoaded,
        'available': isBannerAvailable,
      },
      'interstitial': {
        'loaded': _isInterstitialLoaded,
        'available': isInterstitialAvailable,
      },
      'native': {
        'loaded': _isNativeLoaded,
        'available': isNativeAvailable,
      },
      'enabled': _isEnabled,
      'testMode': _isTestMode,
      'retryCount': _retryCount,
      'cacheSize': _adCache.length,
    };
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitEvent(String eventType, dynamic data) {
    for (var listener in _adListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Ad listener error: $e');
      }
    }
  }

  void addListener(Function(String, dynamic) listener) {
    _adListeners.add(listener);
  }

  void removeListener(Function(String, dynamic) listener) {
    _adListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  void dispose() {
    clearAds();
    _adListeners.clear();
    _adCache.clear();
    _adHistory.clear();
  }
}