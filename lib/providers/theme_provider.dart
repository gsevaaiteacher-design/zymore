// ============================================================
// 📁 FILE: theme_provider.dart
// 📍 LOCATION: lib/providers/theme_provider.dart
// 🎯 PURPOSE: Theme State Management Provider
// 🔗 USED BY: All Screens (main.dart, settings, all widgets)
// 📝 DESCRIPTION:
//    This file manages theme state using Provider:
//    - 5 Themes: Dark, Light, Forest, Sun, Ocean
//    - Theme switching
//    - Theme persistence (SharedPreferences)
//    - Dark mode detection
//    - Event-driven theme changes
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// ============================================================
// 🎯 THEME PROVIDER - State Management
// ============================================================

class ThemeProvider extends ChangeNotifier {
  // ── SINGLETON ──
  static ThemeProvider? _instance;
  static ThemeProvider get instance {
    _instance ??= ThemeProvider();
    return _instance!;
  }

  // ── DEPENDENCIES ──
  final SharedPreferences _prefs;

  // ── STATE ──
  ThemeData _currentTheme;
  String _currentThemeName;
  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ── AVAILABLE THEMES ──
  static const List<String> availableThemes = [
    'dark',
    'light',
    'forest',
    'sun',
    'ocean',
  ];
  static const Map<String, String> themeDisplayNames = {
    'dark': 'Dark',
    'light': 'Light',
    'forest': 'Forest',
    'sun': 'Sun',
    'ocean': 'Ocean',
  };
  static const Map<String, IconData> themeIcons = {
    'dark': Icons.nightlight_round,
    'light': Icons.wb_sunny,
    'forest': Icons.park,
    'sun': Icons.wb_sunny,
    'ocean': Icons.water,
  };
  static const Map<String, Color> themeColors = {
    'dark': Color(0xFF1A1A2E),
    'light': Color(0xFFF5F5F5),
    'forest': Color(0xFF1B2E1B),
    'sun': Color(0xFF1A0E00),
    'ocean': Color(0xFF0A1628),
  };

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _themeListeners = [];

  // ── CONSTRUCTOR ──
  ThemeProvider({SharedPreferences? prefs, String initialTheme = 'dark'})
    : _prefs = prefs ?? (throw Exception('SharedPreferences required')),
      _currentThemeName = initialTheme,
      _currentTheme = _getThemeData(initialTheme) {
    _initTheme();
  }

  // ── INIT THEME ──
  Future<void> _initTheme() async {
    try {
      _isLoading = true;

      // Load saved theme preference
      final savedTheme = _prefs.getString(AppConstants.prefDarkMode) ?? 'dark';

      // Get theme data
      final themeData = _getThemeData(savedTheme);

      // Update state
      _currentThemeName = savedTheme;
      _currentTheme = themeData;
      _isDarkMode = _isThemeDark(savedTheme);

      _emitThemeEvent('theme.init', {
        'theme': savedTheme,
        'isDark': _isDarkMode,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Theme Init Error: $e');
      _errorMessage = 'Failed to load theme';
      _isLoading = false;
      _emitThemeEvent('theme.init.error', {'error': e.toString()});
    }
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  ThemeData get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get themeNames => availableThemes;

  String getThemeDisplayName(String themeName) {
    return themeDisplayNames[themeName] ?? themeName;
  }

  IconData getThemeIcon(String themeName) {
    return themeIcons[themeName] ?? Icons.color_lens;
  }

  Color getThemeColor(String themeName) {
    return themeColors[themeName] ?? Colors.grey;
  }

  // ============================================================
  // 🎨 THEME SWITCHING
  // ============================================================

  /// Set theme by name
  Future<bool> setTheme(String themeName) async {
    if (!availableThemes.contains(themeName)) {
      _setError('Theme "$themeName" not available');
      return false;
    }

    if (themeName == _currentThemeName) {
      return true; // Already on this theme
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get theme data
      final themeData = _getThemeData(themeName);

      // Update state
      _currentThemeName = themeName;
      _currentTheme = themeData;
      _isDarkMode = _isThemeDark(themeName);

      // Save preference
      await _prefs.setString(AppConstants.prefDarkMode, themeName);

      _emitThemeEvent('theme.changed', {
        'oldTheme': _currentThemeName,
        'newTheme': themeName,
        'isDark': _isDarkMode,
      });

      _isLoading = false;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Theme Change Error: $e');
      _setError('Failed to change theme');
      _isLoading = false;
      _emitThemeEvent('theme.change.error', {'error': e.toString()});
      return false;
    }
  }

  /// Toggle between dark and light themes
  Future<bool> toggleTheme() async {
    if (_currentThemeName == 'dark' || _currentThemeName == 'forest') {
      return await setTheme('light');
    } else {
      return await setTheme('dark');
    }
  }

  /// Toggle dark mode on/off
  Future<bool> toggleDarkMode() async {
    if (_isDarkMode) {
      return await setTheme('light');
    } else {
      return await setTheme('dark');
    }
  }

  /// Set random theme (fun feature)
  Future<bool> setRandomTheme() async {
    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % availableThemes.length;
    final themeName = availableThemes[randomIndex];
    return await setTheme(themeName);
  }

  // ============================================================
  // 🎨 THEME DATA HELPERS
  // ============================================================

  static ThemeData _getThemeData(String themeName) {
    switch (themeName) {
      case 'dark':
        return ThemeProvider._createDarkTheme();
      case 'light':
        return ThemeProvider._createLightTheme();
      case 'forest':
        return ThemeProvider._createForestTheme();
      case 'sun':
        return ThemeProvider._createSunTheme();
      case 'ocean':
        return ThemeProvider._createOceanTheme();
      default:
        return ThemeProvider._createDarkTheme();
    }
  }

  static bool _isThemeDark(String themeName) {
    return themeName == 'dark' || themeName == 'forest';
  }

  // ============================================================
  // 🎨 THEME CREATORS (5 Themes)
  // ============================================================

  static ThemeData _createDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      primaryColorDark: AppColors.primaryDark,
      primaryColorLight: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
      cardColor: AppColors.cardBackgroundDark,
      backgroundColor: AppColors.backgroundDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBackgroundDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: Colors.white60,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.cardBackgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData _createLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      primaryColorDark: AppColors.primaryDark,
      primaryColorLight: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      cardColor: AppColors.cardBackground,
      backgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBackground,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData _createForestTheme() {
    const forestPrimary = Color(0xFF2E7D32);
    const forestSecondary = Color(0xFF4CAF50);
    const forestAccent = Color(0xFF81C784);
    const forestBackground = Color(0xFF1B2E1B);
    const forestCard = Color(0xFF2A4A2A);
    const forestText = Color(0xFFC8E6C9);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: forestPrimary,
      primaryColorDark: const Color(0xFF1B5E20),
      primaryColorLight: forestAccent,
      scaffoldBackgroundColor: forestBackground,
      cardColor: forestCard,
      backgroundColor: forestBackground,

      colorScheme: ColorScheme.dark(
        primary: forestPrimary,
        secondary: forestSecondary,
        surface: forestCard,
        background: forestBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: forestText,
        onBackground: forestText,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: forestText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          color: forestText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          color: forestText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          color: forestText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          color: forestText.withOpacity(0.9),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: forestText.withOpacity(0.7),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: forestText.withOpacity(0.5),
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: forestSecondary),
        ),
        labelStyle: TextStyle(color: forestText.withOpacity(0.7)),
        hintStyle: TextStyle(color: forestText.withOpacity(0.4)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),

      cardTheme: CardTheme(
        color: forestCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData _createSunTheme() {
    const sunPrimary = Color(0xFFFF6F00);
    const sunSecondary = Color(0xFFFFB300);
    const sunAccent = Color(0xFFFFD54F);
    const sunBackground = Color(0xFF1A0E00);
    const sunCard = Color(0xFF2A1A00);
    const sunText = Color(0xFFFFE0B2);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: sunPrimary,
      primaryColorDark: const Color(0xFFE65100),
      primaryColorLight: sunAccent,
      scaffoldBackgroundColor: sunBackground,
      cardColor: sunCard,
      backgroundColor: sunBackground,

      colorScheme: ColorScheme.dark(
        primary: sunPrimary,
        secondary: sunSecondary,
        surface: sunCard,
        background: sunBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: sunText,
        onBackground: sunText,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: sunText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          color: sunText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          color: sunText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          color: sunText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          color: sunText.withOpacity(0.9),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: sunText.withOpacity(0.7),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: sunText.withOpacity(0.5),
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: sunSecondary),
        ),
        labelStyle: TextStyle(color: sunText.withOpacity(0.7)),
        hintStyle: TextStyle(color: sunText.withOpacity(0.4)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sunSecondary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),

      cardTheme: CardTheme(
        color: sunCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData _createOceanTheme() {
    const oceanPrimary = Color(0xFF0D47A1);
    const oceanSecondary = Color(0xFF42A5F5);
    const oceanAccent = Color(0xFF64B5F6);
    const oceanBackground = Color(0xFF0A1628);
    const oceanCard = Color(0xFF1A2A4A);
    const oceanText = Color(0xFFB3E5FC);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: oceanPrimary,
      primaryColorDark: const Color(0xFF0D47A1),
      primaryColorLight: oceanAccent,
      scaffoldBackgroundColor: oceanBackground,
      cardColor: oceanCard,
      backgroundColor: oceanBackground,

      colorScheme: ColorScheme.dark(
        primary: oceanPrimary,
        secondary: oceanSecondary,
        surface: oceanCard,
        background: oceanBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: oceanText,
        onBackground: oceanText,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: oceanText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          color: oceanText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          color: oceanText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          color: oceanText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          color: oceanText.withOpacity(0.9),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: oceanText.withOpacity(0.7),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: oceanText.withOpacity(0.5),
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: oceanSecondary),
        ),
        labelStyle: TextStyle(color: oceanText.withOpacity(0.7)),
        hintStyle: TextStyle(color: oceanText.withOpacity(0.4)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),

      cardTheme: CardTheme(
        color: oceanCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ============================================================
  // 📝 ERROR HANDLING
  // ============================================================

  void _setError(String message) {
    _errorMessage = message;
    _emitThemeEvent('theme.error', {'message': message});
  }

  void _clearError() {
    _errorMessage = null;
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitThemeEvent(String eventType, dynamic data) {
    for (var listener in _themeListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Theme listener error: $e');
      }
    }
  }

  void addThemeListener(Function(String, dynamic) listener) {
    _themeListeners.add(listener);
  }

  void removeThemeListener(Function(String, dynamic) listener) {
    _themeListeners.remove(listener);
  }

  // ============================================================
  // 📊 STATISTICS
  // ============================================================

  Map<String, dynamic> getStats() {
    return {
      'currentTheme': _currentThemeName,
      'isDarkMode': _isDarkMode,
      'availableThemes': availableThemes.length,
      'listeners': _themeListeners.length,
      'isLoading': _isLoading,
    };
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  @override
  void dispose() {
    _themeListeners.clear();
    super.dispose();
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR theme_provider.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:shared_preferences/shared_preferences.dart';

 void main() {
   test('ThemeProvider initializes correctly', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = ThemeProvider(prefs: prefs);
     expect(provider.currentThemeName, 'dark');
     expect(provider.availableThemes.length, 5);
     expect(provider.isLoading, false);
   });

   test('ThemeProvider switches themes correctly', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = ThemeProvider(prefs: prefs);
     
     await provider.setTheme('light');
     expect(provider.currentThemeName, 'light');
     expect(provider.isDarkMode, false);
     
     await provider.setTheme('forest');
     expect(provider.currentThemeName, 'forest');
     expect(provider.isDarkMode, true);
   });

   test('ThemeProvider toggleTheme works', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = ThemeProvider(prefs: prefs, initialTheme: 'dark');
     expect(provider.currentThemeName, 'dark');
     
     await provider.toggleTheme();
     expect(provider.currentThemeName, 'light');
     
     await provider.toggleTheme();
     expect(provider.currentThemeName, 'dark');
   });

   test('ThemeProvider getters return correct values', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = ThemeProvider(prefs: prefs);
     
     expect(provider.getThemeDisplayName('dark'), 'Dark');
     expect(provider.getThemeIcon('dark'), Icons.nightlight_round);
     expect(provider.getThemeColor('dark'), const Color(0xFF1A1A2E));
   });

   test('ThemeProvider invalid theme handling', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     
     final provider = ThemeProvider(prefs: prefs);
     
     final result = await provider.setTheme('invalid_theme');
     expect(result, false);
     expect(provider.errorMessage, isNotNull);
   });
 }
*/
