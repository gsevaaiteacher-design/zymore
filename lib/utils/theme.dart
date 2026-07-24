// ============================================================
// 📁 FILE: theme.dart
// 📍 LOCATION: lib/utils/theme.dart
// 🎯 PURPOSE: Complete App Theme System - 5 Themes
// 🔗 USED BY: main.dart, All Screens
// 📝 DESCRIPTION:
//    This file contains complete theme configurations for 5 themes:
//    1. Dark Theme - Night mode with navy base
//    2. Light Theme - Clean white default
//    3. Forest Theme - Nature green vibes
//    4. Sun Theme - Warm golden/orange
//    5. Ocean Theme - Cool blue/sky
//    
//    ALL THEMES follow the Z-FIXER architecture:
//    - No direct module communication
//    - All through dispatcher pattern
//    - Complete error handling
//    - Theme switching with events
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

// ============================================================
// 🎨 THEME PROVIDER - Z-FIXER WIRING COMPLIANT
// ============================================================

class ThemeProvider extends ChangeNotifier {
  // ── STATE ──
  ThemeData _currentTheme;
  String _currentThemeName = 'dark';
  final Map<String, ThemeData> _themes = {};
  
  // ── EVENT BUS (Z-FIXER DISPATCHER PATTERN) ──
  final List<Function(String, ThemeData)> _themeListeners = [];

  // ── CONSTRUCTOR ──
  ThemeProvider({String initialTheme = 'dark'}) 
      : _currentTheme = _createDarkTheme() {
    _initializeThemes();
    _currentThemeName = initialTheme;
    _currentTheme = _themes[initialTheme] ?? _themes['dark']!;
  }

  // ── INITIALIZE ALL 5 THEMES ──
  void _initializeThemes() {
    _themes['dark'] = _createDarkTheme();
    _themes['light'] = _createLightTheme();
    _themes['forest'] = _createForestTheme();
    _themes['sun'] = _createSunTheme();
    _themes['ocean'] = _createOceanTheme();
  }

  // ── GETTERS ──
  ThemeData get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;
  List<String> get themeNames => _themes.keys.toList();
  Map<String, ThemeData> get allThemes => _themes;

  // ── THEME SWITCHING (PUBLISHES EVENT) ──
  void setTheme(String themeName) {
    try {
      final theme = _themes[themeName];
      if (theme == null) {
        throw Exception('Theme "$themeName" not found');
      }

      // ✅ Z-FIXER: Emit event before changing
      _emitThemeEvent('theme.changing', themeName, _currentThemeName);

      // Change theme
      _currentTheme = theme;
      _currentThemeName = themeName;
      notifyListeners();

      // ✅ Z-FIXER: Emit event after changing
      _emitThemeEvent('theme.changed', themeName, _currentThemeName);

      // ✅ Z-FIXER: Store preference (recovery ready)
      _saveThemePreference(themeName);

    } catch (error) {
      // ✅ Z-FIXER: Error handling - recoverable
      _emitThemeEvent('theme.error', themeName, error.toString());
      print('❌ Theme Error: $error');
    }
  }

  // ── TOGGLE DARK/LIGHT (Quick switch) ──
  void toggleTheme() {
    if (_currentThemeName == 'dark') {
      setTheme('light');
    } else if (_currentThemeName == 'light') {
      setTheme('dark');
    } else {
      setTheme('dark');
    }
  }

  // ── CHECK IF DARK MODE ──
  bool get isDarkMode {
    return _currentThemeName == 'dark' || _currentThemeName == 'forest';
  }

  // ── Z-FIXER: EVENT EMISSION ──
  void _emitThemeEvent(String eventType, String themeName, dynamic data) {
    for (var listener in _themeListeners) {
      try {
        listener(eventType, _currentTheme);
      } catch (e) {
        print('❌ Theme listener error: $e');
      }
    }
  }

  // ── Z-FIXER: REGISTER LISTENER ──
  void addThemeListener(Function(String, ThemeData) listener) {
    _themeListeners.add(listener);
  }

  // ── Z-FIXER: REMOVE LISTENER ──
  void removeThemeListener(Function(String, ThemeData) listener) {
    _themeListeners.remove(listener);
  }

  // ── Z-FIXER: RECOVERY - Save preference ──
  Future<void> _saveThemePreference(String themeName) async {
    try {
      // SharedPreferences implementation
      // (To be implemented with storage service)
    } catch (e) {
      print('❌ Theme save error: $e');
    }
  }

  // ── Z-FIXER: RECOVERY - Load saved theme ──
  Future<String?> _loadSavedTheme() async {
    try {
      // SharedPreferences implementation
      return null;
    } catch (e) {
      print('❌ Theme load error: $e');
      return null;
    }
  }

  // ============================================================
  // 🎨 THEME 1: DARK THEME
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: AppColors.cardBackgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        thickness: 1,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.white70),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 THEME 2: LIGHT THEME
  // ============================================================
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardBackground,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.withOpacity(0.1),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 THEME 3: FOREST THEME (Nature - Green)
  // ============================================================
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestSecondary,
          side: BorderSide(color: forestSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: forestCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dividerTheme: DividerThemeData(
        color: forestText.withOpacity(0.1),
        thickness: 1,
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: forestCard,
        selectedItemColor: forestSecondary,
        unselectedItemColor: forestText.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: forestCard,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(color: forestText.withOpacity(0.7)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 THEME 4: SUN THEME (Warm - Golden/Orange)
  // ============================================================
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: sunSecondary,
          side: BorderSide(color: sunSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: sunCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dividerTheme: DividerThemeData(
        color: sunText.withOpacity(0.1),
        thickness: 1,
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: sunCard,
        selectedItemColor: sunSecondary,
        unselectedItemColor: sunText.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: sunCard,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(color: sunText.withOpacity(0.7)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 THEME 5: OCEAN THEME (Cool - Blue/Sky)
  // ============================================================
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: oceanSecondary,
          side: BorderSide(color: oceanSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: oceanCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dividerTheme: DividerThemeData(
        color: oceanText.withOpacity(0.1),
        thickness: 1,
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: oceanCard,
        selectedItemColor: oceanSecondary,
        unselectedItemColor: oceanText.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: oceanCard,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(color: oceanText.withOpacity(0.7)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ============================================================
// 🎨 THEME EXTENSIONS - Helper Methods
// ============================================================

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  bool get isDarkMode {
    final themeProvider = Provider.of<ThemeProvider>(this, listen: false);
    return themeProvider.isDarkMode;
  }
  
  String get currentThemeName {
    final themeProvider = Provider.of<ThemeProvider>(this, listen: false);
    return themeProvider.currentThemeName;
  }
}

// ============================================================
// 🧪 Z-FIXER UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR theme.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:provider/provider.dart';

 void main() {
   testWidgets('ThemeProvider initializes with dark theme', 
       (WidgetTester tester) async {
     final provider = ThemeProvider();
     expect(provider.currentThemeName, 'dark');
     expect(provider.allThemes.length, 5);
   });

   testWidgets('ThemeProvider switches themes correctly', 
       (WidgetTester tester) async {
     final provider = ThemeProvider();
     
     provider.setTheme('light');
     expect(provider.currentThemeName, 'light');
     
     provider.setTheme('forest');
     expect(provider.currentThemeName, 'forest');
     
     provider.setTheme('sun');
     expect(provider.currentThemeName, 'sun');
     
     provider.setTheme('ocean');
     expect(provider.currentThemeName, 'ocean');
   });

   testWidgets('Toggle theme works correctly', 
       (WidgetTester tester) async {
     final provider = ThemeProvider(initialTheme: 'dark');
     expect(provider.currentThemeName, 'dark');
     
     provider.toggleTheme();
     expect(provider.currentThemeName, 'light');
     
     provider.toggleTheme();
     expect(provider.currentThemeName, 'dark');
   });

   testWidgets('All themes have required colors', 
       (WidgetTester tester) async {
     final provider = ThemeProvider();
     
     for (var theme in provider.allThemes.values) {
       expect(theme.primaryColor, isNotNull);
       expect(theme.scaffoldBackgroundColor, isNotNull);
       expect(theme.textTheme.bodyLarge, isNotNull);
       expect(theme.colorScheme, isNotNull);
     }
   });

   testWidgets('Theme change emits event', 
       (WidgetTester tester) async {
     final provider = ThemeProvider();
     bool eventReceived = false;
     
     provider.addThemeListener((eventType, theme) {
       eventReceived = true;
     });
     
     provider.setTheme('light');
     expect(eventReceived, true);
   });
 }
*/