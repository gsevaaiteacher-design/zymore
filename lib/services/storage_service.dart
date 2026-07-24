// ============================================================
// 📁 FILE: storage_service.dart
// 📍 LOCATION: lib/services/storage_service.dart
// 🎯 PURPOSE: Storage Service - Firebase Storage Operations
// 🔗 USED BY: Upload Screen, Product Provider, Download Service
// 📝 DESCRIPTION:
//    This file handles all Firebase Storage operations:
//    - Upload images/files
//    - Download files
//    - Delete files
//    - Get download URLs
//    - File compression
//    - File validation
//    - Progress tracking
//    - Caching
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

// ============================================================
// 📁 IMPORT CONSTANTS
// ============================================================
import '../utils/constants.dart';

// ============================================================
// 💾 STORAGE SERVICE - Singleton
// ============================================================

class StorageService {
  // ── SINGLETON ──
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ── FIREBASE INSTANCES ──
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── CONFIG ──
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 20 * 1024 * 1024; // 20MB
  static const int imageQuality = 80;
  static const int maxImageDimension = 1920;

  // ── CACHE ──
  final Map<String, String> _urlCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(hours: 1);

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _storageListeners = [];

  // ── PROGRESS STREAMS ──
  final Map<String, StreamController<double>> _progressControllers = {};

  // ============================================================
  // 📤 UPLOAD OPERATIONS
  // ============================================================

  /// Upload an image file
  Future<String?> uploadImage(
    File file,
    String path, {
    bool compress = true,
    int? quality,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file
      final validation = await validateFile(file);
      if (!validation.isValid) {
        _emitEvent('storage.upload.error', {'error': validation.errorMessage});
        return null;
      }

      // Compress image if needed
      File uploadFile = file;
      if (compress) {
        uploadFile = await compressImage(
          file,
          quality: quality ?? imageQuality,
          maxDimension: maxImageDimension,
        );
      }

      // Create storage reference
      final ref = _storage.ref(path);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': _auth.currentUser?.uid ?? 'anonymous',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload file
      UploadTask uploadTask = ref.putFile(uploadFile, metadata);

      // Track progress
      if (onProgress != null) {
        final subscription = uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
        // Cancel subscription when done
        await uploadTask.whenComplete(() => subscription.cancel());
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cache URL
      _addToCache(path, downloadUrl);

      _emitEvent('storage.upload.success', {
        'path': path,
        'size': uploadFile.lengthSync(),
      });

      return downloadUrl;
    } catch (e) {
      print('❌ Upload Image Error: $e');
      _emitEvent('storage.upload.error', {'error': e.toString()});
      return null;
    }
  }

  /// Upload multiple images
  Future<List<String?>> uploadImages(
    List<File> files,
    String basePath, {
    bool compress = true,
    Function(int, double)? onProgress,
  }) async {
    final List<String?> urls = [];
    int completed = 0;

    for (var file in files) {
      final fileName = path.basename(file.path);
      final fullPath = '$basePath/$fileName';

      final url = await uploadImage(
        file,
        fullPath,
        compress: compress,
        onProgress: (progress) {
          if (onProgress != null) {
            onProgress(completed, progress);
          }
        },
      );

      urls.add(url);
      completed++;
    }

    return urls;
  }

  /// Upload a file (any type)
  Future<String?> uploadFile(
    File file,
    String path, {
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file
      final validation = await validateFile(file);
      if (!validation.isValid) {
        _emitEvent('storage.upload.error', {'error': validation.errorMessage});
        return null;
      }

      // Create storage reference
      final ref = _storage.ref(path);

      // Upload file
      UploadTask uploadTask = ref.putFile(file);

      // Track progress
      if (onProgress != null) {
        final subscription = uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
        await uploadTask.whenComplete(() => subscription.cancel());
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cache URL
      _addToCache(path, downloadUrl);

      _emitEvent('storage.upload.success', {
        'path': path,
        'size': file.lengthSync(),
      });

      return downloadUrl;
    } catch (e) {
      print('❌ Upload File Error: $e');
      _emitEvent('storage.upload.error', {'error': e.toString()});
      return null;
    }
  }

  /// Upload from bytes
  Future<String?> uploadBytes(
    Uint8List bytes,
    String path, {
    String contentType = 'application/octet-stream',
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(path);

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedBy': _auth.currentUser?.uid ?? 'anonymous',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask = ref.putData(bytes, metadata);

      if (onProgress != null) {
        final subscription = uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
        await uploadTask.whenComplete(() => subscription.cancel());
      }

      final TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _addToCache(path, downloadUrl);

      _emitEvent('storage.upload.success', {
        'path': path,
        'size': bytes.length,
      });

      return downloadUrl;
    } catch (e) {
      print('❌ Upload Bytes Error: $e');
      _emitEvent('storage.upload.error', {'error': e.toString()});
      return null;
    }
  }

  // ============================================================
  // 📥 DOWNLOAD OPERATIONS
  // ============================================================

  /// Download file from Firebase Storage
  Future<File?> downloadFile(
    String path,
    String destination, {
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(path);
      final file = File(destination);

      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);

      // Download file
      final downloadTask = ref.writeToFile(file);

      // Track progress
      if (onProgress != null) {
        final subscription = downloadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
        await downloadTask.whenComplete(() => subscription.cancel());
      }

      await downloadTask;

      _emitEvent('storage.download.success', {
        'path': path,
        'destination': destination,
      });

      return file;
    } catch (e) {
      print('❌ Download File Error: $e');
      _emitEvent('storage.download.error', {'error': e.toString()});
      return null;
    }
  }

  /// Get download URL for a file
  Future<String?> getDownloadUrl(String path, {bool useCache = true}) async {
    try {
      // Check cache
      if (useCache) {
        final cached = _getFromCache(path);
        if (cached != null) return cached;
      }

      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();

      // Cache URL
      if (useCache) {
        _addToCache(path, url);
      }

      return url;
    } catch (e) {
      print('❌ Get Download URL Error: $e');
      _emitEvent('storage.url.error', {'path': path, 'error': e.toString()});
      return null;
    }
  }

  /// Get multiple download URLs
  Future<Map<String, String?>> getDownloadUrls(List<String> paths) async {
    final results = <String, String?>{};

    for (var path in paths) {
      results[path] = await getDownloadUrl(path);
    }

    return results;
  }

  // ============================================================
  // 🗑️ DELETE OPERATIONS
  // ============================================================

  /// Delete a file from Firebase Storage
  Future<bool> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();

      // Invalidate cache
      _invalidateCache(path);

      _emitEvent('storage.delete.success', {'path': path});
      return true;
    } catch (e) {
      print('❌ Delete File Error: $e');
      _emitEvent('storage.delete.error', {'path': path, 'error': e.toString()});
      return false;
    }
  }

  /// Delete multiple files
  Future<Map<String, bool>> deleteFiles(List<String> paths) async {
    final results = <String, bool>{};

    for (var path in paths) {
      results[path] = await deleteFile(path);
    }

    return results;
  }

  /// Delete a folder and all its contents
  Future<bool> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref(folderPath);

      // List all files in folder
      final result = await ref.listAll();

      // Delete each file
      for (var item in result.items) {
        await item.delete();
      }

      // Invalidate cache for all items
      _invalidateCacheStartingWith(folderPath);

      _emitEvent('storage.folder.delete.success', {'path': folderPath});
      return true;
    } catch (e) {
      print('❌ Delete Folder Error: $e');
      _emitEvent('storage.folder.delete.error', {
        'path': folderPath,
        'error': e.toString(),
      });
      return false;
    }
  }

  // ============================================================
  // 📋 METADATA OPERATIONS
  // ============================================================

  /// Get file metadata
  Future<Map<String, dynamic>?> getMetadata(String path) async {
    try {
      final ref = _storage.ref(path);
      final metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      print('❌ Get Metadata Error: $e');
      return null;
    }
  }

  /// Update file metadata
  Future<bool> updateMetadata(
    String path,
    Map<String, String> customMetadata,
  ) async {
    try {
      final ref = _storage.ref(path);
      final metadata = SettableMetadata(customMetadata: customMetadata);
      await ref.updateMetadata(metadata);

      _emitEvent('storage.metadata.updated', {'path': path});
      return true;
    } catch (e) {
      print('❌ Update Metadata Error: $e');
      return false;
    }
  }

  // ============================================================
  // 📁 LIST OPERATIONS
  // ============================================================

  /// List files in a folder
  Future<List<String>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref(folderPath);
      final result = await ref.listAll();

      return result.items.map((item) => item.fullPath).toList();
    } catch (e) {
      print('❌ List Files Error: $e');
      return [];
    }
  }

  /// List files in a folder with pagination
  Future<List<String>> listFilesPaginated(
    String folderPath, {
    int maxResults = 100,
    String? pageToken,
  }) async {
    try {
      final ref = _storage.ref(folderPath);
      final result = await ref.list(
        ListOptions(maxResults: maxResults, pageToken: pageToken),
      );

      return result.items.map((item) => item.fullPath).toList();
    } catch (e) {
      print('❌ List Files Paginated Error: $e');
      return [];
    }
  }

  // ============================================================
  // 🖼️ IMAGE PROCESSING
  // ============================================================

  /// Compress image
  Future<File> compressImage(
    File file, {
    int quality = 80,
    int maxDimension = 1920,
  }) async {
    try {
      // Read image
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return file;

      // Resize if too large
      if (image.width > maxDimension || image.height > maxDimension) {
        final scale = maxDimension / max(image.width, image.height);
        final newWidth = (image.width * scale).round();
        final newHeight = (image.height * scale).round();
        image = img.copyResize(image, width: newWidth, height: newHeight);
      }

      // Encode with compression
      final compressed = img.encodeJpg(image, quality: quality);

      // Write to temporary file
      final tempFile = File('${file.path}.compressed.jpg');
      await tempFile.writeAsBytes(compressed);

      return tempFile;
    } catch (e) {
      print('❌ Compress Image Error: $e');
      return file;
    }
  }

  /// Compress multiple images
  Future<List<File>> compressImages(
    List<File> files, {
    int quality = 80,
    int maxDimension = 1920,
  }) async {
    final List<File> compressed = [];

    for (var file in files) {
      final compressedFile = await compressImage(
        file,
        quality: quality,
        maxDimension: maxDimension,
      );
      compressed.add(compressedFile);
    }

    return compressed;
  }

  /// Convert image format
  Future<File> convertImageFormat(
    File file,
    String format, {
    int quality = 80,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return file;

      List<int> encoded;
      final extension = format.toLowerCase();

      switch (extension) {
        case 'png':
          encoded = img.encodePng(image);
          break;
        case 'webp':
          encoded = img.encodeWebp(image, quality: quality);
          break;
        case 'jpg':
        case 'jpeg':
        default:
          encoded = img.encodeJpg(image, quality: quality);
          break;
      }

      final newPath = '${file.path}.$extension';
      final newFile = File(newPath);
      await newFile.writeAsBytes(encoded);

      return newFile;
    } catch (e) {
      print('❌ Convert Image Format Error: $e');
      return file;
    }
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  /// Validate file
  Future<StorageValidationResult> validateFile(File file) async {
    final result = StorageValidationResult();

    try {
      // Check file exists
      if (!await file.exists()) {
        result.isValid = false;
        result.errorMessage = 'File does not exist';
        return result;
      }

      // Check file size
      final size = await file.length();
      if (size > maxFileSize) {
        result.isValid = false;
        result.errorMessage =
            'File too large (max ${maxFileSize ~/ (1024 * 1024)}MB)';
        return result;
      }

      // Check file type
      final extension = path.extension(file.path).toLowerCase();
      final allowedExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.svg',
        '.mp4',
        '.mp3',
        '.pdf',
        '.zip',
      ];

      if (!allowedExtensions.contains(extension) && extension.isNotEmpty) {
        result.isValid = false;
        result.errorMessage = 'File type not allowed';
        return result;
      }

      // Validate image dimensions if it's an image
      if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
        try {
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null) {
            result.width = image.width;
            result.height = image.height;
            result.isValid = true;
          }
        } catch (e) {
          // Not a valid image
          result.isValid = false;
          result.errorMessage = 'Invalid image file';
          return result;
        }
      }

      result.isValid = true;
      result.fileSize = size;
      result.fileType = extension.replaceFirst('.', '');
    } catch (e) {
      result.isValid = false;
      result.errorMessage = 'File validation failed: $e';
    }

    return result;
  }

  // ============================================================
  // 📁 PATH HELPERS
  // ============================================================

  /// Generate a unique path for a file
  String generateUniquePath(String folder, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    final extension = path.extension(fileName);
    final name = path.basenameWithoutExtension(fileName);
    final uniqueName = '${name}_${timestamp}_$random$extension';
    return '$folder/$uniqueName';
  }

  /// Generate a path for a product image
  String getProductImagePath(String productId, String fileName) {
    return 'products/$productId/images/$fileName';
  }

  /// Generate a path for a product thumbnail
  String getProductThumbnailPath(String productId, String fileName) {
    return 'products/$productId/thumbnails/$fileName';
  }

  /// Generate a path for a user avatar
  String getUserAvatarPath(String userId) {
    return 'users/$userId/avatar.jpg';
  }

  // ============================================================
  // 💾 CACHE MANAGEMENT
  // ============================================================

  void _addToCache(String key, String url) {
    _urlCache[key] = url;
    _cacheTimestamps[key] = DateTime.now();
  }

  String? _getFromCache(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _invalidateCache(key);
      return null;
    }
    return _urlCache[key];
  }

  void _invalidateCache(String key) {
    _urlCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  void _invalidateCacheStartingWith(String prefix) {
    _urlCache.removeWhere((key, _) => key.startsWith(prefix));
    _cacheTimestamps.removeWhere((key, _) => key.startsWith(prefix));
  }

  void clearCache() {
    _urlCache.clear();
    _cacheTimestamps.clear();
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitEvent(String eventType, dynamic data) {
    for (var listener in _storageListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Storage listener error: $e');
      }
    }
  }

  void addListener(Function(String, dynamic) listener) {
    _storageListeners.add(listener);
  }

  void removeListener(Function(String, dynamic) listener) {
    _storageListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  void dispose() {
    _storageListeners.clear();
    clearCache();
    _progressControllers.forEach((_, controller) => controller.close());
    _progressControllers.clear();
  }
}

// ============================================================
// 📊 STORAGE VALIDATION RESULT
// ============================================================

class StorageValidationResult {
  bool isValid = true;
  String? errorMessage;
  int? fileSize;
  String? fileType;
  int? width;
  int? height;

  StorageValidationResult({this.isValid = true});
}
