// ============================================================
// 📁 FILE: theme.dart
// 📍 LOCATION: lib/utils/theme.dart
// 🎯 PURPOSE: Theme Helper Extensions
// 🔗 USED BY: main.dart, All Screens
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import '../providers/theme_provider.dart';

// ============================================================
// 🎨 THEME EXTENSIONS - Helper Methods
// ============================================================

extension ThemeContextExtension on BuildContext {
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
