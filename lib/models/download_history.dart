// ============================================================
// 📁 FILE: download_history.dart
// 📍 LOCATION: lib/models/download_history.dart
// 🎯 PURPOSE: Download History Data Model
// 🔗 USED BY: History Screen, Download Service
// 📝 DESCRIPTION:
//    This file defines the Download History data model with:
//    - Download basic information
//    - Product details
//    - Download status and progress
//    - File information
//    - Firestore serialization
//    - JSON serialization
//    - Validation methods
//    - Status management
//
//    Z-FIXER COMPLIANT:
//    - Contract-first design
//    - Complete error handling
//    - Immutable where possible
//    - Telemetry ready
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// 📥 DOWNLOAD HISTORY MODEL
// ============================================================

class DownloadHistory {
  // ── BASIC INFO ──
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final String productThumbnail;

  // ── DOWNLOAD INFO ──
  final String downloadUrl;
  final String fileType;
  final int fileSize;
  final String fileName;

  // ── STATUS ──
  final DownloadStatus status;
  final int progress;
  final String? errorMessage;

  // ── DATES ──
  final DateTime downloadedAt;
  final DateTime? completedAt;
  final DateTime? lastUpdated;

  // ── LOCAL PATH ──
  final String? localPath;

  // ============================================================
  // 🏗️ CONSTRUCTORS
  // ============================================================

  DownloadHistory({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productThumbnail,
    required this.downloadUrl,
    this.fileType = '',
    this.fileSize = 0,
    this.fileName = '',
    this.status = DownloadStatus.pending,
    this.progress = 0,
    this.errorMessage,
    DateTime? downloadedAt,
    this.completedAt,
    this.lastUpdated,
    this.localPath,
  }) : downloadedAt = downloadedAt ?? DateTime.now();

  // ── FROM FIRESTORE ──
  factory DownloadHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return DownloadHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productThumbnail: data['productThumbnail'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      fileType: data['fileType'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      fileName: data['fileName'] ?? '',
      status: DownloadStatus.fromString(data['status'] ?? 'pending'),
      progress: data['progress'] ?? 0,
      errorMessage: data['errorMessage'],
      downloadedAt:
          (data['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
      localPath: data['localPath'],
    );
  }

  // ── FROM JSON ──
  factory DownloadHistory.fromJson(Map<String, dynamic> json) {
    return DownloadHistory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productThumbnail: json['productThumbnail'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      fileName: json['fileName'] ?? '',
      status: DownloadStatus.fromString(json['status'] ?? 'pending'),
      progress: json['progress'] ?? 0,
      errorMessage: json['errorMessage'],
      downloadedAt: DateTime.parse(json['downloadedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      localPath: json['localPath'],
    );
  }

  // ── EMPTY ──
  factory DownloadHistory.empty() {
    return DownloadHistory(
      id: '',
      userId: '',
      productId: '',
      productTitle: '',
      productThumbnail: '',
      downloadUrl: '',
    );
  }

  // ============================================================
  // 🔄 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'productTitle': productTitle,
      'productThumbnail': productThumbnail,
      'downloadUrl': downloadUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'fileName': fileName,
      'status': status.toStringValue(),
      'progress': progress,
      'errorMessage': errorMessage,
      'downloadedAt': Timestamp.fromDate(downloadedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
      'localPath': localPath,
    };
  }

  // ============================================================
  // 📋 TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productTitle': productTitle,
      'productThumbnail': productThumbnail,
      'downloadUrl': downloadUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'fileName': fileName,
      'status': status.toStringValue(),
      'progress': progress,
      'errorMessage': errorMessage,
      'downloadedAt': downloadedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'localPath': localPath,
    };
  }

  // ============================================================
  // 📋 COPY WITH
  // ============================================================

  DownloadHistory copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productTitle,
    String? productThumbnail,
    String? downloadUrl,
    String? fileType,
    int? fileSize,
    String? fileName,
    DownloadStatus? status,
    int? progress,
    String? errorMessage,
    DateTime? downloadedAt,
    DateTime? completedAt,
    DateTime? lastUpdated,
    String? localPath,
  }) {
    return DownloadHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productThumbnail: productThumbnail ?? this.productThumbnail,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      localPath: localPath ?? this.localPath,
    );
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool get isValid {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        productId.isNotEmpty &&
        productTitle.isNotEmpty &&
        downloadUrl.isNotEmpty;
  }

  bool get isComplete {
    return status == DownloadStatus.completed;
  }

  bool get isPending {
    return status == DownloadStatus.pending;
  }

  bool get isDownloading {
    return status == DownloadStatus.downloading;
  }

  bool get isFailed {
    return status == DownloadStatus.failed;
  }

  bool get isPaused {
    return status == DownloadStatus.paused;
  }

  bool get hasError {
    return errorMessage != null && errorMessage!.isNotEmpty;
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  String get statusDisplay {
    switch (status) {
      case DownloadStatus.pending:
        return 'Pending';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get statusEmoji {
    switch (status) {
      case DownloadStatus.pending:
        return '⏳';
      case DownloadStatus.downloading:
        return '📥';
      case DownloadStatus.completed:
        return '✅';
      case DownloadStatus.failed:
        return '❌';
      case DownloadStatus.paused:
        return '⏸️';
      case DownloadStatus.cancelled:
        return '🚫';
    }
  }

  String get progressDisplay {
    if (status == DownloadStatus.completed) return 'Completed';
    if (status == DownloadStatus.failed) return 'Failed';
    return '$progress%';
  }

  String get fileSizeDisplay {
    if (fileSize >= 1073741824) {
      return '${(fileSize / 1073741824).toStringAsFixed(1)} GB';
    } else if (fileSize >= 1048576) {
      return '${(fileSize / 1048576).toStringAsFixed(1)} MB';
    } else if (fileSize >= 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$fileSize B';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(downloadedAt);

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
  }

  bool get isCompletedToday {
    if (completedAt == null) return false;
    final now = DateTime.now();
    return completedAt!.year == now.year &&
        completedAt!.month == now.month &&
        completedAt!.day == now.day;
  }

  bool get isDownloadedThisWeek {
    if (completedAt == null) return false;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return completedAt!.isAfter(weekAgo);
  }

  // ============================================================
  // 🔍 HELPER METHODS
  // ============================================================

  DownloadHistory updateProgress(int newProgress, {DownloadStatus? newStatus}) {
    return copyWith(
      progress: newProgress,
      status: newStatus ?? status,
      lastUpdated: DateTime.now(),
    );
  }

  DownloadHistory markComplete() {
    return copyWith(
      status: DownloadStatus.completed,
      progress: 100,
      completedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  DownloadHistory markFailed(String error) {
    return copyWith(
      status: DownloadStatus.failed,
      errorMessage: error,
      lastUpdated: DateTime.now(),
    );
  }

  DownloadHistory markPaused() {
    return copyWith(status: DownloadStatus.paused, lastUpdated: DateTime.now());
  }

  DownloadHistory resumeDownload() {
    return copyWith(
      status: DownloadStatus.downloading,
      errorMessage: null,
      lastUpdated: DateTime.now(),
    );
  }

  DownloadHistory cancelDownload() {
    return copyWith(
      status: DownloadStatus.cancelled,
      lastUpdated: DateTime.now(),
    );
  }

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return productTitle.toLowerCase().contains(lowerQuery) ||
        fileName.toLowerCase().contains(lowerQuery) ||
        fileType.toLowerCase().contains(lowerQuery) ||
        statusDisplay.toLowerCase().contains(lowerQuery);
  }

  // ============================================================
  // 📝 STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'DownloadHistory(id: $id, product: $productTitle, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 📊 DOWNLOAD STATUS ENUM
// ============================================================

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
  cancelled;

  String toStringValue() {
    switch (this) {
      case DownloadStatus.pending:
        return 'pending';
      case DownloadStatus.downloading:
        return 'downloading';
      case DownloadStatus.completed:
        return 'completed';
      case DownloadStatus.failed:
        return 'failed';
      case DownloadStatus.paused:
        return 'paused';
      case DownloadStatus.cancelled:
        return 'cancelled';
    }
  }

  static DownloadStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      case 'paused':
        return DownloadStatus.paused;
      case 'cancelled':
        return DownloadStatus.cancelled;
      default:
        return DownloadStatus.pending;
    }
  }

  bool get isActive {
    return this == DownloadStatus.pending ||
        this == DownloadStatus.downloading ||
        this == DownloadStatus.paused;
  }

  bool get isComplete {
    return this == DownloadStatus.completed;
  }

  bool get isFailed {
    return this == DownloadStatus.failed || this == DownloadStatus.cancelled;
  }

  bool get canResume {
    return this == DownloadStatus.paused || this == DownloadStatus.failed;
  }

  bool get canCancel {
    return this == DownloadStatus.pending ||
        this == DownloadStatus.downloading ||
        this == DownloadStatus.paused;
  }

  bool get canRetry {
    return this == DownloadStatus.failed;
  }
}

// ============================================================
// 📊 DOWNLOAD STATS
// ============================================================

class DownloadStats {
  final int totalDownloads;
  final int completedDownloads;
  final int pendingDownloads;
  final int failedDownloads;
  final int downloadingDownloads;
  final int pausedDownloads;
  final int cancelledDownloads;
  final int totalSizeBytes;
  final int completedSizeBytes;

  DownloadStats({
    this.totalDownloads = 0,
    this.completedDownloads = 0,
    this.pendingDownloads = 0,
    this.failedDownloads = 0,
    this.downloadingDownloads = 0,
    this.pausedDownloads = 0,
    this.cancelledDownloads = 0,
    this.totalSizeBytes = 0,
    this.completedSizeBytes = 0,
  });

  factory DownloadStats.fromHistory(List<DownloadHistory> history) {
    int total = history.length;
    int completed = history
        .where((d) => d.status == DownloadStatus.completed)
        .length;
    int pending = history
        .where((d) => d.status == DownloadStatus.pending)
        .length;
    int failed = history.where((d) => d.status == DownloadStatus.failed).length;
    int downloading = history
        .where((d) => d.status == DownloadStatus.downloading)
        .length;
    int paused = history.where((d) => d.status == DownloadStatus.paused).length;
    int cancelled = history
        .where((d) => d.status == DownloadStatus.cancelled)
        .length;

    int totalSize = history.fold(0, (sum, d) => sum + d.fileSize);
    int completedSize = history
        .where((d) => d.status == DownloadStatus.completed)
        .fold(0, (sum, d) => sum + d.fileSize);

    return DownloadStats(
      totalDownloads: total,
      completedDownloads: completed,
      pendingDownloads: pending,
      failedDownloads: failed,
      downloadingDownloads: downloading,
      pausedDownloads: paused,
      cancelledDownloads: cancelled,
      totalSizeBytes: totalSize,
      completedSizeBytes: completedSize,
    );
  }

  double get completionRate {
    if (totalDownloads == 0) return 0.0;
    return completedDownloads / totalDownloads;
  }

  String get completionRateDisplay {
    return '${(completionRate * 100).toStringAsFixed(1)}%';
  }

  String get totalSizeDisplay {
    if (totalSizeBytes >= 1073741824) {
      return '${(totalSizeBytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (totalSizeBytes >= 1048576) {
      return '${(totalSizeBytes / 1048576).toStringAsFixed(1)} MB';
    } else if (totalSizeBytes >= 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$totalSizeBytes B';
    }
  }

  String get completedSizeDisplay {
    if (completedSizeBytes >= 1073741824) {
      return '${(completedSizeBytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (completedSizeBytes >= 1048576) {
      return '${(completedSizeBytes / 1048576).toStringAsFixed(1)} MB';
    } else if (completedSizeBytes >= 1024) {
      return '${(completedSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$completedSizeBytes B';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDownloads': totalDownloads,
      'completedDownloads': completedDownloads,
      'pendingDownloads': pendingDownloads,
      'failedDownloads': failedDownloads,
      'downloadingDownloads': downloadingDownloads,
      'pausedDownloads': pausedDownloads,
      'cancelledDownloads': cancelledDownloads,
      'totalSizeBytes': totalSizeBytes,
      'completedSizeBytes': completedSizeBytes,
    };
  }

  factory DownloadStats.fromJson(Map<String, dynamic> json) {
    return DownloadStats(
      totalDownloads: json['totalDownloads'] ?? 0,
      completedDownloads: json['completedDownloads'] ?? 0,
      pendingDownloads: json['pendingDownloads'] ?? 0,
      failedDownloads: json['failedDownloads'] ?? 0,
      downloadingDownloads: json['downloadingDownloads'] ?? 0,
      pausedDownloads: json['pausedDownloads'] ?? 0,
      cancelledDownloads: json['cancelledDownloads'] ?? 0,
      totalSizeBytes: json['totalSizeBytes'] ?? 0,
      completedSizeBytes: json['completedSizeBytes'] ?? 0,
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR download_history.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   test('DownloadHistory creates correctly', () {
     final history = DownloadHistory(
       id: 'history_1',
       userId: 'user_1',
       productId: 'product_1',
       productTitle: 'Test Product',
       productThumbnail: 'test.jpg',
       downloadUrl: 'https://example.com/file.zip',
       fileSize: 1024,
       fileName: 'file.zip',
     );

     expect(history.id, 'history_1');
     expect(history.productTitle, 'Test Product');
     expect(history.status, DownloadStatus.pending);
     expect(history.isValid, true);
   });

   test('DownloadHistory status helpers work', () {
     final pending = DownloadHistory(
       id: '1', userId: 'u1', productId: 'p1',
       productTitle: 'P1', productThumbnail: 't1',
       downloadUrl: 'url',
     );

     expect(pending.isPending, true);
     expect(pending.isComplete, false);

     final completed = pending.copyWith(status: DownloadStatus.completed);
     expect(completed.isComplete, true);
     expect(completed.isPending, false);
   });

   test('DownloadHistory progress updates work', () {
     final history = DownloadHistory(
       id: '1', userId: 'u1', productId: 'p1',
       productTitle: 'P1', productThumbnail: 't1',
       downloadUrl: 'url',
     );

     final updated = history.updateProgress(50);
     expect(updated.progress, 50);

     final completed = updated.markComplete();
     expect(completed.status, DownloadStatus.completed);
     expect(completed.progress, 100);
     expect(completed.completedAt, isNotNull);
   });

   test('DownloadHistory error handling works', () {
     final history = DownloadHistory(
       id: '1', userId: 'u1', productId: 'p1',
       productTitle: 'P1', productThumbnail: 't1',
       downloadUrl: 'url',
     );

     final failed = history.markFailed('Network error');
     expect(failed.status, DownloadStatus.failed);
     expect(failed.errorMessage, 'Network error');
     expect(failed.hasError, true);
   });

   test('DownloadStatus enum works correctly', () {
     expect(DownloadStatus.pending.toStringValue(), 'pending');
     expect(DownloadStatus.fromString('completed'), DownloadStatus.completed);
     expect(DownloadStatus.pending.isActive, true);
     expect(DownloadStatus.completed.isComplete, true);
     expect(DownloadStatus.failed.canRetry, true);
   });

   test('DownloadStats calculates correctly', () {
     final history = [
       DownloadHistory(
         id: '1', userId: 'u1', productId: 'p1',
         productTitle: 'P1', productThumbnail: 't1',
         downloadUrl: 'url1', fileSize: 100,
         status: DownloadStatus.completed,
       ),
       DownloadHistory(
         id: '2', userId: 'u1', productId: 'p2',
         productTitle: 'P2', productThumbnail: 't2',
         downloadUrl: 'url2', fileSize: 200,
         status: DownloadStatus.pending,
       ),
       DownloadHistory(
         id: '3', userId: 'u1', productId: 'p3',
         productTitle: 'P3', productThumbnail: 't3',
         downloadUrl: 'url3', fileSize: 300,
         status: DownloadStatus.failed,
       ),
     ];

     final stats = DownloadStats.fromHistory(history);
     expect(stats.totalDownloads, 3);
     expect(stats.completedDownloads, 1);
     expect(stats.pendingDownloads, 1);
     expect(stats.failedDownloads, 1);
     expect(stats.totalSizeBytes, 600);
     expect(stats.completedSizeBytes, 100);
     expect(stats.completionRate, 0.3333333333333333);
   });
 }
*/
