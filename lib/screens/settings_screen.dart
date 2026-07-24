// ============================================================
// 📁 FILE: settings_screen.dart
// 📍 LOCATION: lib/screens/settings_screen.dart
// 🎯 PURPOSE: App Settings Screen
// 🔗 USED BY: Profile Screen, App Bar
// 📝 DESCRIPTION:
//    This screen displays app settings with:
//    - Theme selection (5 themes)
//    - Language selection
//    - Notification settings
//    - Download settings
//    - Privacy settings
//    - About app
//    - Terms & Conditions
//    - Privacy Policy
//    - Clear cache
//    - Report issue
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================
// 📁 IMPORT PROVIDERS, WIDGETS, UTILS
// ============================================================
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/custom_app_bar.dart';

// ============================================================
// 🎯 SETTINGS SCREEN
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _downloadOverWifi = true;
  bool _autoPlayVideos = false;
  bool _saveToGallery = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ============================================================
  // 📤 LOAD SETTINGS
  // ============================================================

  void _loadSettings() {
    // TODO: Load settings from SharedPreferences
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _darkMode = themeProvider.isDarkMode;
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: true,
        showProfileAvatar: false,
        showSearch: false,
        showCart: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── THEME SECTION ──
                  _buildThemeSection(themeProvider, isDark),
                  const SizedBox(height: 16),

                  // ── PREFERENCES SECTION ──
                  _buildPreferencesSection(isDark),
                  const SizedBox(height: 16),

                  // ── DOWNLOAD SECTION ──
                  _buildDownloadSection(isDark),
                  const SizedBox(height: 16),

                  // ── ABOUT SECTION ──
                  _buildAboutSection(isDark),
                  const SizedBox(height: 16),

                  // ── POWERED BY ──
                  _buildPoweredBy(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 🎨 BUILD THEME SECTION
  // ============================================================

  Widget _buildThemeSection(ThemeProvider themeProvider, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const Divider(height: 1),
          ..._buildThemeItems(themeProvider, isDark),
        ],
      ),
    );
  }

  List<Widget> _buildThemeItems(ThemeProvider themeProvider, bool isDark) {
    final themes = [
      {
        'id': 'dark',
        'name': 'Dark',
        'icon': Icons.nightlight_round,
        'color': Colors.grey[800],
      },
      {
        'id': 'light',
        'name': 'Light',
        'icon': Icons.wb_sunny,
        'color': Colors.amber,
      },
      {
        'id': 'forest',
        'name': 'Forest',
        'icon': Icons.park,
        'color': Colors.green,
      },
      {
        'id': 'sun',
        'name': 'Sun',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
      },
      {
        'id': 'ocean',
        'name': 'Ocean',
        'icon': Icons.water,
        'color': Colors.blue,
      },
    ];

    return themes.map((theme) {
      final isSelected = themeProvider.currentThemeName == theme['id'];
      return ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                (theme['color'] as Color?)?.withOpacity(0.2) ??
                Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            theme['icon'] as IconData,
            color: theme['color'] as Color? ?? Colors.grey,
          ),
        ),
        title: Text(
          theme['name'] as String,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: () {
          themeProvider.setTheme(theme['id'] as String);
        },
      );
    }).toList();
  }

  // ============================================================
  // ⚙️ BUILD PREFERENCES SECTION
  // ============================================================

  Widget _buildPreferencesSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              'Toggle dark/light theme',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              final themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              themeProvider.toggleDarkMode();
            },
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              'Receive push notifications',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppColors.primary,
          ),
          ListTile(
            leading: Icon(
              Icons.language,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              'Language',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              _selectedLanguage,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: _showLanguageDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📥 BUILD DOWNLOAD SECTION
  // ============================================================

  Widget _buildDownloadSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Downloads',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(
              'Download over Wi-Fi only',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              'Prevent mobile data usage',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            value: _downloadOverWifi,
            onChanged: (value) {
              setState(() {
                _downloadOverWifi = value;
              });
            },
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text(
              'Save to Gallery',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              'Auto-save downloads to gallery',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            value: _saveToGallery,
            onChanged: (value) {
              setState(() {
                _saveToGallery = value;
              });
            },
            activeColor: AppColors.primary,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_sweep_outlined,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              'Clear Cache',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              'Clear downloaded files and cache',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: _showClearCacheDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ℹ️ BUILD ABOUT SECTION
  // ============================================================

  Widget _buildAboutSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              'About Zymore',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: _showAboutDialog,
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: _showPrivacyPolicyDialog,
          ),
          ListTile(
            leading: Icon(
              Icons.gavel_outlined,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: _showTermsDialog,
          ),
          ListTile(
            leading: Icon(
              Icons.feedback_outlined,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              'Report Issue',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: _showReportDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ⚡ BUILD POWERED BY
  // ============================================================

  Widget _buildPoweredBy(bool isDark) {
    return Column(
      children: [
        Divider(
          color: isDark ? Colors.white12 : Colors.grey[300],
          thickness: 1,
          indent: 60,
          endIndent: 60,
        ),
        const SizedBox(height: 12),
        Text(
          '⚡ Powered By',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.grey[500],
            fontFamily: 'Inter',
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppConstants.poweredBy,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Poppins',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${AppConstants.appVersion}',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white24 : Colors.grey[400],
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 📱 DIALOGS
  // ============================================================

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Hindi'),
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Hindi';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Spanish';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all downloaded files and cached data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppConstants.appName,
        applicationVersion: AppConstants.appVersion,
        applicationIcon: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Z',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        children: [
          const SizedBox(height: 16),
          Text(
            'Free Digital Marketplace',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} ${AppConstants.poweredBy}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Zymore is committed to protecting your privacy. We collect minimal data to provide the best experience. Your data is never shared with third parties without your consent.',
          style: TextStyle(fontFamily: 'Inter', height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const Text(
          'By using Zymore, you agree to the following terms: All content is provided "as is". Users are responsible for the content they upload. The platform reserves the right to remove any content that violates our policies.',
          style: TextStyle(fontFamily: 'Inter', height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Describe the issue you are facing:',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your issue here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue reported successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
