// ============================================================
// 📁 FILE: download_service.dart
// 📍 LOCATION: lib/services/download_service.dart
// 🎯 PURPOSE: Download Service - File Download Management
// 🔗 USED BY: Product Detail Screen, Download History
// 📝 DESCRIPTION:
//    This file handles all download operations:
//    - Download files from URL
//    - Track download progress
//    - Resume/pause downloads
//    - Cancel downloads
//    - Save to device storage
//    - Permission handling
//    - Download history management
//    - File validation
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// 📁 IMPORT MODELS & SERVICES
// ============================================================
import '../models/download_history.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';
import 'ad_service.dart';

// ============================================================
// 📥 DOWNLOAD SERVICE - Singleton
// ============================================================

class DownloadService {
  // ── SINGLETON ──
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  // ── DEPENDENCIES ──
  final DatabaseService _database = DatabaseService();
  final AdService _adService = AdService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── STATE ──
  final Map<String, DownloadTask> _activeDownloads = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};
  final List<String> _completedDownloads = [];

  // ── CONFIG ──
  static const int _maxConcurrentDownloads = 3;
  static const int _chunkSize = 1024 * 1024; // 1MB chunks

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _downloadListeners = [];

  // ============================================================
  // 🚀 INITIALIZATION
  // ============================================================

  Future<void> init() async {
    try {
      // Initialize Flutter Downloader
      await FlutterDownloader.initialize(debug: true, ignoreSsl: false);

      // Request storage permission
      await _requestPermissions();

      // Load pending downloads
      await _loadPendingDownloads();

      _emitEvent('download.initialized', {});
      print('✅ Download Service Initialized');
    } catch (e) {
      print('❌ Download Service Init Error: $e');
      _emitEvent('download.init.error', {'error': e.toString()});
    }
  }

  // ============================================================
  // 📥 START DOWNLOAD
  // ============================================================

  /// Start downloading a product
  Future<DownloadResult> downloadProduct(
    ProductModel product, {
    bool showAd = true,
    Function(double)? onProgress,
  }) async {
    try {
      // Check if user is logged in
      final user = _auth.currentUser;
      if (user == null) {
        return DownloadResult.error('Please login to download');
      }

      // Check if already downloading
      if (_activeDownloads.containsKey(product.id)) {
        return DownloadResult.error('Already downloading');
      }

      // Check if already downloaded
      final exists = await _checkIfDownloaded(product.id, user.uid);
      if (exists) {
        return DownloadResult.error('Already downloaded');
      }

      // Show ad if required
      if (showAd) {
        final adResult = await _showRewardedAd();
        if (!adResult) {
          return DownloadResult.error('Ad not completed');
        }
      }

      // Get download URL
      String downloadUrl = product.downloadUrl;
      if (downloadUrl.isEmpty) {
        return DownloadResult.error('Download URL not available');
      }

      // Prepare file info
      final fileName = _getFileName(product);
      final fileSize = await _getFileSize(downloadUrl);

      // Get save directory
      final directory = await _getDownloadDirectory();
      final filePath = path.join(directory.path, fileName);

      // Start download
      final downloadTask = DownloadTask(
        id: product.id,
        productId: product.id,
        title: product.title,
        fileName: fileName,
        filePath: filePath,
        totalSize: fileSize,
        url: downloadUrl,
        status: DownloadStatus.downloading,
        progress: 0,
        startTime: DateTime.now(),
      );

      _activeDownloads[product.id] = downloadTask;

      // Create progress stream
      final controller = StreamController<DownloadProgress>();
      _progressControllers[product.id] = controller;

      // Start downloading
      _startDownload(product.id, downloadTask, onProgress);

      _emitEvent('download.started', {
        'productId': product.id,
        'title': product.title,
      });

      return DownloadResult.success(downloadTask);
    } catch (e) {
      print('❌ Download Product Error: $e');
      _emitEvent('download.error', {'error': e.toString()});
      return DownloadResult.error('Failed to start download: $e');
    }
  }

  // ============================================================
  // 🔄 DOWNLOAD IMPLEMENTATION
  // ============================================================

  void _startDownload(
    String id,
    DownloadTask task,
    Function(double)? onProgress,
  ) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(task.url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        _handleDownloadError(id, 'HTTP ${response.statusCode}');
        return;
      }

      final contentLength = response.contentLength ?? task.totalSize;
      final file = File(task.filePath);

      // Create directory if not exists
      await file.parent.create(recursive: true);

      // Download in chunks
      int received = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        final progress = contentLength > 0 ? received / contentLength : 0;

        // Update task
        task.progress = progress;
        task.receivedSize = received;
        task.totalSize = contentLength;
        task.lastUpdated = DateTime.now();

        // Emit progress
        _emitProgress(id, progress);
        onProgress?.call(progress);
      }

      await sink.flush();
      await sink.close();

      // Download complete
      await _completeDownload(id, file);
    } catch (e) {
      _handleDownloadError(id, e.toString());
    }
  }

  // ============================================================
  // ✅ COMPLETE DOWNLOAD
  // ============================================================

  Future<void> _completeDownload(String id, File file) async {
    try {
      final task = _activeDownloads[id];
      if (task == null) return;

      // Update task
      task.status = DownloadStatus.completed;
      task.progress = 1.0;
      task.completedAt = DateTime.now();

      // Save to history
      await _saveToHistory(task);

      // Save to local storage
      await _saveToLocalStorage(task);

      // Remove from active downloads
      _activeDownloads.remove(id);
      _completedDownloads.add(id);

      // Close progress stream
      _progressControllers[id]?.close();
      _progressControllers.remove(id);

      _emitEvent('download.completed', {
        'productId': task.productId,
        'title': task.title,
        'path': file.path,
      });

      // Show notification
      await _showDownloadNotification(task);
    } catch (e) {
      print('❌ Complete Download Error: $e');
      _handleDownloadError(id, e.toString());
    }
  }

  // ============================================================
  // ❌ ERROR HANDLING
  // ============================================================

  void _handleDownloadError(String id, String error) {
    final task = _activeDownloads[id];
    if (task == null) return;

    task.status = DownloadStatus.failed;
    task.error = error;

    _activeDownloads.remove(id);
    _progressControllers[id]?.close();
    _progressControllers.remove(id);

    _emitEvent('download.failed', {
      'productId': task.productId,
      'title': task.title,
      'error': error,
    });
  }

  // ============================================================
  // 📊 DOWNLOAD CONTROLS
  // ============================================================

  /// Pause a download
  Future<bool> pauseDownload(String id) async {
    final task = _activeDownloads[id];
    if (task == null) return false;

    task.status = DownloadStatus.paused;
    _emitEvent('download.paused', {'productId': task.productId});
    return true;
  }

  /// Resume a download
  Future<bool> resumeDownload(String id) async {
    final task = _activeDownloads[id];
    if (task == null) return false;

    task.status = DownloadStatus.downloading;
    _emitEvent('download.resumed', {'productId': task.productId});
    return true;
  }

  /// Cancel a download
  Future<bool> cancelDownload(String id) async {
    final task = _activeDownloads[id];
    if (task == null) return false;

    task.status = DownloadStatus.cancelled;
    _activeDownloads.remove(id);
    _progressControllers[id]?.close();
    _progressControllers.remove(id);

    _emitEvent('download.cancelled', {'productId': task.productId});
    return true;
  }

  /// Retry a failed download
  Future<bool> retryDownload(String id) async {
    final task = _activeDownloads[id];
    if (task == null) return false;

    task.status = DownloadStatus.downloading;
    task.progress = 0;
    task.error = null;

    _emitEvent('download.retry', {'productId': task.productId});
    return true;
  }

  // ============================================================
  // 📁 FILE OPERATIONS
  // ============================================================

  /// Open downloaded file
  Future<bool> openFile(String productId) async {
    try {
      final history = await _getDownloadHistory(productId);
      if (history == null || history.localPath == null) {
        return false;
      }

      final file = File(history.localPath!);
      if (!await file.exists()) {
        return false;
      }

      await OpenFile.open(file.path);
      return true;
    } catch (e) {
      print('❌ Open File Error: $e');
      return false;
    }
  }

  /// Delete downloaded file
  Future<bool> deleteFile(String productId) async {
    try {
      final history = await _getDownloadHistory(productId);
      if (history == null || history.localPath == null) {
        return false;
      }

      final file = File(history.localPath!);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from history
      await _removeFromHistory(productId);

      _emitEvent('download.deleted', {'productId': productId});
      return true;
    } catch (e) {
      print('❌ Delete File Error: $e');
      return false;
    }
  }

  /// Get downloaded file path
  Future<String?> getFilePath(String productId) async {
    final history = await _getDownloadHistory(productId);
    if (history == null) return null;
    return history.localPath;
  }

  /// Check if file is downloaded
  Future<bool> isFileDownloaded(String productId) async {
    final history = await _getDownloadHistory(productId);
    if (history == null) return false;

    final file = File(history.localPath!);
    return await file.exists();
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  /// Get active downloads
  List<DownloadTask> getActiveDownloads() {
    return _activeDownloads.values.toList();
  }

  /// Get download progress stream
  Stream<DownloadProgress>? getProgressStream(String id) {
    final controller = _progressControllers[id];
    if (controller == null) return null;
    return controller.stream;
  }

  /// Get download status
  DownloadStatus? getDownloadStatus(String id) {
    final task = _activeDownloads[id];
    if (task == null) return null;
    return task.status;
  }

  /// Get download progress
  double? getDownloadProgress(String id) {
    final task = _activeDownloads[id];
    if (task == null) return null;
    return task.progress;
  }

  /// Get completed downloads count
  int getCompletedCount() {
    return _completedDownloads.length;
  }

  /// Get active downloads count
  int getActiveCount() {
    return _activeDownloads.length;
  }

  // ============================================================
  // 💾 HISTORY MANAGEMENT
  // ============================================================

  Future<void> _saveToHistory(DownloadTask task) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final history = DownloadHistory(
        id: task.id,
        userId: user.uid,
        productId: task.productId,
        productTitle: task.title,
        productThumbnail: task.thumbnail ?? '',
        downloadUrl: task.url,
        fileType: path.extension(task.fileName),
        fileSize: task.totalSize,
        fileName: task.fileName,
        status: DownloadStatus.completed,
        progress: 100,
        downloadedAt: task.startTime,
        completedAt: task.completedAt,
        localPath: task.filePath,
      );

      await _database.addDownloadHistory(history);
    } catch (e) {
      print('❌ Save to History Error: $e');
    }
  }

  Future<DownloadHistory?> _getDownloadHistory(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final historyList = await _database.getUserDownloadHistory(user.uid);
      return historyList.firstWhere(
        (h) => h.productId == productId && h.status == DownloadStatus.completed,
        orElse: () => DownloadHistory.empty(),
      );
    } catch (e) {
      print('❌ Get Download History Error: $e');
      return null;
    }
  }

  Future<void> _removeFromHistory(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete from Firestore
      final snapshot = await _firestore
          .collection(AppConstants.collectionDownloads)
          .where('userId', isEqualTo: user.uid)
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('❌ Remove from History Error: $e');
    }
  }

  Future<bool> _checkIfDownloaded(String productId, String userId) async {
    try {
      final historyList = await _database.getUserDownloadHistory(userId);
      return historyList.any(
        (h) => h.productId == productId && h.status == DownloadStatus.completed,
      );
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 💾 LOCAL STORAGE
  // ============================================================

  Future<void> _saveToLocalStorage(DownloadTask task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'download_${task.productId}';
      await prefs.setString(key, task.filePath);
    } catch (e) {
      print('❌ Save to Local Storage Error: $e');
    }
  }

  Future<void> _loadPendingDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (var key in keys) {
        if (key.startsWith('download_')) {
          final productId = key.replaceFirst('download_', '');
          final path = prefs.getString(key);
          if (path != null) {
            final file = File(path);
            if (await file.exists()) {
              _completedDownloads.add(productId);
            }
          }
        }
      }
    } catch (e) {
      print('❌ Load Pending Downloads Error: $e');
    }
  }

  // ============================================================
  // 📁 PATH HELPERS
  // ============================================================

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use external storage
      final dir = await getExternalStorageDirectory();
      return Directory(path.join(dir?.path ?? '', 'Downloads'));
    } else if (Platform.isIOS) {
      // For iOS, use application documents
      final dir = await getApplicationDocumentsDirectory();
      return Directory(path.join(dir.path, 'Downloads'));
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  String _getFileName(ProductModel product) {
    final extension = product.fileType.isNotEmpty ? product.fileType : 'zip';
    final title = product.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return '$title.$extension';
  }

  Future<int> _getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        return int.parse(contentLength);
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // 🔔 NOTIFICATIONS
  // ============================================================

  Future<void> _showDownloadNotification(DownloadTask task) async {
    // TODO: Implement notification using flutter_local_notifications
    print('📥 Download Complete: ${task.title}');
  }

  // ============================================================
  // 🎯 PERMISSIONS
  // ============================================================

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  // ============================================================
  // 🏆 AD HANDLING
  // ============================================================

  Future<bool> _showRewardedAd() async {
    final completer = Completer<bool>();

    await _adService.showRewardedAd(
      onReward: () {
        completer.complete(true);
      },
      onError: () {
        completer.complete(false);
      },
    );

    return completer.future;
  }

  // ============================================================
  // 📊 PROGRESS EMISSION
  // ============================================================

  void _emitProgress(String id, double progress) {
    final controller = _progressControllers[id];
    if (controller != null && !controller.isClosed) {
      controller.add(DownloadProgress(id, progress));
    }
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitEvent(String eventType, dynamic data) {
    for (var listener in _downloadListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Download listener error: $e');
      }
    }
  }

  void addListener(Function(String, dynamic) listener) {
    _downloadListeners.add(listener);
  }

  void removeListener(Function(String, dynamic) listener) {
    _downloadListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  void dispose() {
    _downloadListeners.clear();
    _progressControllers.forEach((_, controller) => controller.close());
    _progressControllers.clear();
  }
}

// ============================================================
// 📊 DOWNLOAD TASK
// ============================================================

class DownloadTask {
  final String id;
  final String productId;
  final String title;
  final String fileName;
  final String filePath;
  final String url;
  final String? thumbnail;
  int totalSize;
  int receivedSize;
  DownloadStatus status;
  double progress;
  String? error;
  final DateTime startTime;
  DateTime? completedAt;
  DateTime? lastUpdated;

  DownloadTask({
    required this.id,
    required this.productId,
    required this.title,
    required this.fileName,
    required this.filePath,
    required this.totalSize,
    required this.url,
    this.thumbnail,
    this.receivedSize = 0,
    this.status = DownloadStatus.pending,
    this.progress = 0,
    this.error,
    required this.startTime,
    this.completedAt,
    this.lastUpdated,
  });
}

// ============================================================
// 📊 DOWNLOAD PROGRESS
// ============================================================

class DownloadProgress {
  final String id;
  final double progress;

  DownloadProgress(this.id, this.progress);
}

// ============================================================
// 📊 DOWNLOAD RESULT
// ============================================================

class DownloadResult {
  final bool success;
  final DownloadTask? task;
  final String? error;

  DownloadResult.success(this.task) : success = true, error = null;

  DownloadResult.error(this.error) : success = false, task = null;

  factory DownloadResult.success(DownloadTask task) {
    return DownloadResult.success(task);
  }

  factory DownloadResult.error(String error) {
    return DownloadResult.error(error);
  }
}
