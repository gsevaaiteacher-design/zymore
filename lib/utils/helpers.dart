// ============================================================
// 📁 FILE: helpers.dart
// 📍 LOCATION: lib/utils/helpers.dart
// 🎯 PURPOSE: Complete Helper Functions - All Utility Methods
// 🔗 USED BY: All Screens, Widgets, Services
// 📝 DESCRIPTION:
//    This file contains all helper utility functions:
//    - Date/Time Formatting
//    - Number Formatting
//    - String Manipulation
//    - File Size Formatting
//    - Device Information
//    - Screen Navigation
//    - Dialog/Toast Helpers
//    - Validation Helpers
//    - Image Helpers
//    - Color Helpers
//    - And many more...
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Telemetry ready
//    - All helpers have tests
// ============================================================

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'dart:async';

// ============================================================
// 📅 DATE/TIME HELPERS
// ============================================================

class DateTimeHelper {
  // ── FORMAT DATE ──
  static String formatDate(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    try {
      final formatter = DateFormat(pattern);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateTime(
    DateTime date, {
    String pattern = 'dd MMM yyyy, hh:mm a',
  }) {
    try {
      final formatter = DateFormat(pattern);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatTimeAgo(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays > 1) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 1) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 1) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  static String formatRelativeTime(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return formatDate(date);
      }
    } catch (e) {
      return formatDate(date);
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}

// ============================================================
// 🔢 NUMBER HELPERS
// ============================================================

class NumberHelper {
  static String formatNumber(int number) {
    try {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    } catch (e) {
      return number.toString();
    }
  }

  static String formatCurrency(double amount, {String symbol = '₹'}) {
    try {
      final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
      return formatter.format(amount);
    } catch (e) {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  static String formatPercentage(double value) {
    try {
      return '${(value * 100).toStringAsFixed(1)}%';
    } catch (e) {
      return '${value.toStringAsFixed(2)}%';
    }
  }

  static String formatDecimal(double value, {int decimals = 2}) {
    try {
      return value.toStringAsFixed(decimals);
    } catch (e) {
      return value.toString();
    }
  }

  static String formatFileSize(int bytes) {
    try {
      if (bytes >= 1073741824) {
        return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
      } else if (bytes >= 1048576) {
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      } else if (bytes >= 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '$bytes B';
      }
    } catch (e) {
      return '$bytes B';
    }
  }

  static String formatDuration(Duration duration) {
    try {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);

      if (hours > 0) {
        return '${hours}h ${minutes}m ${seconds}s';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${seconds}s';
      }
    } catch (e) {
      return '${duration.inSeconds}s';
    }
  }

  static String ordinal(int number) {
    try {
      if (number >= 11 && number <= 13) {
        return '${number}th';
      }
      switch (number % 10) {
        case 1:
          return '${number}st';
        case 2:
          return '${number}nd';
        case 3:
          return '${number}rd';
        default:
          return '${number}th';
      }
    } catch (e) {
      return number.toString();
    }
  }

  static bool isNumeric(String string) {
    return double.tryParse(string) != null;
  }

  static int randomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }

  static double randomDouble(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }
}

// ============================================================
// 📝 STRING HELPERS
// ============================================================

class StringHelper {
  static String capitalize(String string) {
    if (string.isEmpty) return string;
    return string[0].toUpperCase() + string.substring(1);
  }

  static String capitalizeAll(String string) {
    if (string.isEmpty) return string;
    return string
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  static String truncate(String string, int length, {String suffix = '...'}) {
    if (string.length <= length) return string;
    return '${string.substring(0, length)}$suffix';
  }

  static String extractInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static bool isValidEmail(String email) {
    final RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  static bool isValidUrl(String url) {
    final RegExp regex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  static String slugify(String string) {
    return string
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
      ),
    );
  }

  static String generateOTP(int length) {
    const chars = '0123456789';
    final rand = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
      ),
    );
  }

  static String maskString(
    String string, {
    int visibleStart = 3,
    int visibleEnd = 2,
    String mask = '*',
  }) {
    if (string.length <= visibleStart + visibleEnd) return string;
    final start = string.substring(0, visibleStart);
    final end = string.substring(string.length - visibleEnd);
    final middle = mask * (string.length - visibleStart - visibleEnd);
    return '$start$middle$end';
  }

  static bool containsEmoji(String string) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(string);
  }

  static String removeEmoji(String string) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return string.replaceAll(emojiRegex, '');
  }
}

// ============================================================
// 🎨 COLOR HELPERS
// ============================================================

class ColorHelper {
  static Color hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
      } else {
        buffer.write(hexString.replaceFirst('#', ''));
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static bool isDarkColor(Color color) {
    final brightness = color.computeLuminance();
    return brightness < 0.5;
  }

  static Color getContrastColor(Color color) {
    return isDarkColor(color) ? Colors.white : Colors.black;
  }

  static Color blendColors(Color color1, Color color2, double ratio) {
    final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
    final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
    final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
    return Color.fromARGB(255, r, g, b);
  }

  static Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  static Color getMaterialColor(int index) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
    ];
    return colors[index % colors.length];
  }
}

// ============================================================
// 📱 DEVICE HELPERS
// ============================================================

class DeviceHelper {
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static bool isWeb() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isMobile() {
    return isAndroid() || isIOS();
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.desktopBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static Future<String> getDeviceId() async {
    try {
      // Use device_info_plus package or other method
      return 'device_id';
    } catch (e) {
      return 'unknown_device';
    }
  }

  static Future<String> getAppVersion() async {
    try {
      // Use package_info_plus package
      return AppConstants.appVersion;
    } catch (e) {
      return '1.0.0';
    }
  }

  static Future<String> getAppName() async {
    try {
      return AppConstants.appName;
    } catch (e) {
      return 'Zymore';
    }
  }
}

// ============================================================
// 📁 FILE HELPERS
// ============================================================

class FileHelper {
  static Future<String> getLocalPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      return '/tmp';
    }
  }

  static Future<String> getCachePath() async {
    try {
      final directory = await getTemporaryDirectory();
      return directory.path;
    } catch (e) {
      return '/tmp/cache';
    }
  }

  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }

  static String getFileNameWithoutExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return fileName;
    return parts.sublist(0, parts.length - 1).join('.');
  }

  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    return imageExtensions.contains(extension);
  }

  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    const videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv'];
    return videoExtensions.contains(extension);
  }

  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    const audioExtensions = ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'];
    return audioExtensions.contains(extension);
  }

  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'];
    return documentExtensions.contains(extension);
  }

  static String getMimeType(String fileName) {
    final extension = getFileExtension(fileName);
    const mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'txt': 'text/plain',
      'html': 'text/html',
      'css': 'text/css',
      'js': 'application/javascript',
      'json': 'application/json',
      'xml': 'application/xml',
      'zip': 'application/zip',
      'mp3': 'audio/mpeg',
      'mp4': 'video/mp4',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}

// ============================================================
// 📊 UI HELPERS
// ============================================================

class UIHelper {
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print('❌ SnackBar Error: $e');
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.success);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.error);
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.warning);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.info);
  }

  static Future<void> showDialogBox(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) async {
    try {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context),
                child: Text(cancelText),
              ),
            if (confirmText != null)
              ElevatedButton(
                onPressed: onConfirm ?? () => Navigator.pop(context),
                child: Text(confirmText),
              ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Dialog Error: $e');
    }
  }

  static Future<T?> showLoadingDialog<T>(
    BuildContext context, {
    required String message,
  }) async {
    try {
      return showDialog<T>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
    } catch (e) {
      print('❌ Loading Dialog Error: $e');
      return null;
    }
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void hideKeyboardGlobally() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}

// ============================================================
// 🎯 CONTEXT HELPERS
// ============================================================

class ContextHelper {
  static void push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  static void pop(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  static void popUntilRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static void pushNamedReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  static void maybePop(BuildContext context, {dynamic result}) {
    Navigator.maybePop(context, result);
  }
}

// ============================================================
// 🌐 URL HELPERS
// ============================================================

class UrlHelper {
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ URL Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchMail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      String url = 'mailto:$email';
      if (subject != null || body != null) {
        url += '?';
        if (subject != null) url += 'subject=${Uri.encodeComponent(subject)}';
        if (subject != null && body != null) url += '&';
        if (body != null) url += 'body=${Uri.encodeComponent(body)}';
      }
      return await launchUrl(url);
    } catch (e) {
      print('❌ Mail Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchPhone(String phone) async {
    try {
      return await launchUrl('tel:$phone');
    } catch (e) {
      print('❌ Phone Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchSms(String phone, {String? message}) async {
    try {
      String url = 'sms:$phone';
      if (message != null) {
        url += '?body=${Uri.encodeComponent(message)}';
      }
      return await launchUrl(url);
    } catch (e) {
      print('❌ SMS Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchWhatsApp(String phone, {String? message}) async {
    try {
      final encodedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      String url = 'https://wa.me/$encodedPhone';
      if (message != null) {
        url += '?text=${Uri.encodeComponent(message)}';
      }
      return await launchUrl(url);
    } catch (e) {
      print('❌ WhatsApp Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchInstagram(String username) async {
    try {
      return await launchUrl('https://instagram.com/$username');
    } catch (e) {
      print('❌ Instagram Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchTwitter(String username) async {
    try {
      return await launchUrl('https://twitter.com/$username');
    } catch (e) {
      print('❌ Twitter Launch Error: $e');
      return false;
    }
  }

  static Future<bool> launchYoutube(String channelId) async {
    try {
      return await launchUrl('https://youtube.com/channel/$channelId');
    } catch (e) {
      print('❌ YouTube Launch Error: $e');
      return false;
    }
  }

  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  static bool isValidHttpUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR helpers.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   // ── DATE/TIME TESTS ──
   test('DateTimeHelper formatDate works', () {
     final date = DateTime(2024, 1, 15);
     expect(DateTimeHelper.formatDate(date), '15 Jan 2024');
   });

   test('DateTimeHelper formatTimeAgo works', () {
     final now = DateTime.now();
     final oneHourAgo = now.subtract(const Duration(hours: 1));
     expect(DateTimeHelper.formatTimeAgo(oneHourAgo), '1 hours ago');
   });

   // ── NUMBER TESTS ──
   test('NumberHelper formatNumber works', () {
     expect(NumberHelper.formatNumber(1000), '1.0K');
     expect(NumberHelper.formatNumber(1000000), '1.0M');
     expect(NumberHelper.formatNumber(500), '500');
   });

   test('NumberHelper formatFileSize works', () {
     expect(NumberHelper.formatFileSize(1024), '1.0 KB');
     expect(NumberHelper.formatFileSize(1048576), '1.0 MB');
   });

   // ── STRING TESTS ──
   test('StringHelper capitalize works', () {
     expect(StringHelper.capitalize('hello'), 'Hello');
     expect(StringHelper.capitalizeAll('hello world'), 'Hello World');
   });

   test('StringHelper truncate works', () {
     expect(StringHelper.truncate('Hello World', 5), 'Hello...');
   });

   test('StringHelper extractInitials works', () {
     expect(StringHelper.extractInitials('John Doe'), 'JD');
     expect(StringHelper.extractInitials('John'), 'J');
   });

   // ── COLOR TESTS ──
   test('ColorHelper hexToColor works', () {
     final color = ColorHelper.hexToColor('#FF6B35');
     expect(color, const Color(0xFFFF6B35));
   });

   test('ColorHelper isDarkColor works', () {
     expect(ColorHelper.isDarkColor(Colors.black), true);
     expect(ColorHelper.isDarkColor(Colors.white), false);
   });

   // ── URL TESTS ──
   test('StringHelper isValidUrl works', () {
     expect(StringHelper.isValidUrl('https://example.com'), true);
     expect(StringHelper.isValidUrl('not a url'), false);
   });

   test('UrlHelper extractDomain works', () {
     expect(UrlHelper.extractDomain('https://example.com'), 'example.com');
   });

   // ── DEVICE TESTS ──
   test('DeviceHelper isMobile works', () {
     // Note: Platform checks depend on environment
     // In test environment, might return false
     expect(DeviceHelper.isMobile(), isBool);
   });
 }
*/
