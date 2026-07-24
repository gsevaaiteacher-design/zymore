// ============================================================
// 📁 FILE: product_model.dart
// 📍 LOCATION: lib/models/product_model.dart
// 🎯 PURPOSE: Product Data Model
// 🔗 USED BY: Product Provider, Detail Screen, Upload Screen
// 📝 DESCRIPTION:
//    This file defines the Product data model with:
//    - Product basic information
//    - Media and file details
//    - Analytics and statistics
//    - Seller information
//    - Private fields for seller only
//    - Firestore serialization
//    - JSON serialization
//    - Validation methods
//
//    Z-FIXER COMPLIANT:
//    - Contract-first design
//    - Complete error handling
//    - Immutable where possible
//    - Telemetry ready
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// 📦 PRODUCT MODEL
// ============================================================

class ProductModel {
  // ── BASIC INFO ──
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;

  // ── MEDIA ──
  final List<String> images;
  final String thumbnail;
  final List<String> mockups;

  // ── FILE INFO ──
  final int fileSize;
  final String fileType;
  final String downloadUrl;
  final bool isLargeFile;

  // ── ANALYTICS (Public) ──
  final int views;
  final int downloads;
  final int likes;
  final double rating;
  final int ratingCount;

  // ── SELLER INFO ──
  final String sellerId;
  final String sellerName;
  final String sellerPhoto;

  // ── DATES ──
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  // ── PRIVATE FIELDS (Only seller can see) ──
  final int privateViews;
  final PrivateStats privateStats;

  // ── LOCAL STATE (Not stored in Firestore) ──
  bool isLiked;

  // ============================================================
  // 🏗️ CONSTRUCTORS
  // ============================================================

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    this.images = const [],
    required this.thumbnail,
    this.mockups = const [],
    this.fileSize = 0,
    this.fileType = '',
    this.downloadUrl = '',
    this.isLargeFile = false,
    this.views = 0,
    this.downloads = 0,
    this.likes = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhoto = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.privateViews = 0,
    PrivateStats? privateStats,
    this.isLiked = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       privateStats = privateStats ?? PrivateStats();

  // ── FROM FIRESTORE ──
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      thumbnail: data['thumbnail'] ?? '',
      mockups: List<String>.from(data['mockups'] ?? []),
      fileSize: data['fileSize'] ?? 0,
      fileType: data['fileType'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      isLargeFile: data['isLargeFile'] ?? false,
      views: data['views'] ?? 0,
      downloads: data['downloads'] ?? 0,
      likes: data['likes'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhoto: data['sellerPhoto'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      privateViews: data['privateViews'] ?? 0,
      privateStats: data['privateStats'] != null
          ? PrivateStats.fromMap(data['privateStats'])
          : PrivateStats(),
      isLiked: false,
    );
  }

  // ── EMPTY PRODUCT ──
  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      title: '',
      description: '',
      category: '',
      thumbnail: '',
      sellerId: '',
      sellerName: '',
    );
  }

  // ── FROM JSON ──
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      thumbnail: json['thumbnail'] ?? '',
      mockups: List<String>.from(json['mockups'] ?? []),
      fileSize: json['fileSize'] ?? 0,
      fileType: json['fileType'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      isLargeFile: json['isLargeFile'] ?? false,
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerPhoto: json['sellerPhoto'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
      privateViews: json['privateViews'] ?? 0,
      privateStats: json['privateStats'] != null
          ? PrivateStats.fromJson(json['privateStats'])
          : PrivateStats(),
      isLiked: json['isLiked'] ?? false,
    );
  }

  // ============================================================
  // 🔄 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'images': images,
      'thumbnail': thumbnail,
      'mockups': mockups,
      'fileSize': fileSize,
      'fileType': fileType,
      'downloadUrl': downloadUrl,
      'isLargeFile': isLargeFile,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'rating': rating,
      'ratingCount': ratingCount,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhoto': sellerPhoto,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'privateViews': privateViews,
      'privateStats': privateStats.toMap(),
    };
  }

  // ============================================================
  // 📋 TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'images': images,
      'thumbnail': thumbnail,
      'mockups': mockups,
      'fileSize': fileSize,
      'fileType': fileType,
      'downloadUrl': downloadUrl,
      'isLargeFile': isLargeFile,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'rating': rating,
      'ratingCount': ratingCount,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhoto': sellerPhoto,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'privateViews': privateViews,
      'privateStats': privateStats.toJson(),
      'isLiked': isLiked,
    };
  }

  // ============================================================
  // 📋 COPY WITH
  // ============================================================

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    List<String>? images,
    String? thumbnail,
    List<String>? mockups,
    int? fileSize,
    String? fileType,
    String? downloadUrl,
    bool? isLargeFile,
    int? views,
    int? downloads,
    int? likes,
    double? rating,
    int? ratingCount,
    String? sellerId,
    String? sellerName,
    String? sellerPhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? privateViews,
    PrivateStats? privateStats,
    bool? isLiked,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      mockups: mockups ?? this.mockups,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isLargeFile: isLargeFile ?? this.isLargeFile,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
      likes: likes ?? this.likes,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhoto: sellerPhoto ?? this.sellerPhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      privateViews: privateViews ?? this.privateViews,
      privateStats: privateStats ?? this.privateStats,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool get isValid {
    return id.isNotEmpty &&
        title.isNotEmpty &&
        description.isNotEmpty &&
        category.isNotEmpty &&
        thumbnail.isNotEmpty &&
        sellerId.isNotEmpty;
  }

  bool get hasImages {
    return images.isNotEmpty;
  }

  bool get hasMockups {
    return mockups.isNotEmpty;
  }

  bool get isComplete {
    return isValid && hasImages && downloadUrl.isNotEmpty;
  }

  bool get canDownload {
    return isActive && downloadUrl.isNotEmpty;
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  String get categoryDisplayName {
    final names = {
      'wallpaper': 'Wallpaper',
      'icon': 'Icon',
      'art': 'Art',
      'asset': 'Asset',
    };
    return names[category] ?? category;
  }

  String get categoryEmoji {
    final emojis = {
      'wallpaper': '🖼️',
      'icon': '🎯',
      'art': '🎨',
      'asset': '📦',
    };
    return emojis[category] ?? '📁';
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

  String get ratingDisplay {
    if (ratingCount == 0) return 'No ratings';
    return '${rating.toStringAsFixed(1)} ⭐ (${ratingCount})';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  // ============================================================
  // 🔍 HELPER METHODS
  // ============================================================

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
        categoryDisplayName.toLowerCase().contains(lowerQuery);
  }

  bool isInCategory(String categoryId) {
    return category == categoryId;
  }

  bool isOwner(String userId) {
    return sellerId == userId;
  }

  // ============================================================
  // 📝 STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 📊 PRIVATE STATS (Only seller can see)
// ============================================================

class PrivateStats {
  final Map<String, int> dailyViews;
  final Map<String, int> dailyDownloads;
  final Map<String, int> deviceInfo;
  final Map<String, int> locationStats;

  PrivateStats({
    this.dailyViews = const {},
    this.dailyDownloads = const {},
    this.deviceInfo = const {},
    this.locationStats = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyViews': dailyViews,
      'dailyDownloads': dailyDownloads,
      'deviceInfo': deviceInfo,
      'locationStats': locationStats,
    };
  }

  factory PrivateStats.fromMap(Map<String, dynamic> map) {
    return PrivateStats(
      dailyViews: Map<String, int>.from(map['dailyViews'] ?? {}),
      dailyDownloads: Map<String, int>.from(map['dailyDownloads'] ?? {}),
      deviceInfo: Map<String, int>.from(map['deviceInfo'] ?? {}),
      locationStats: Map<String, int>.from(map['locationStats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory PrivateStats.fromJson(Map<String, dynamic> json) => fromMap(json);

  PrivateStats copyWith({
    Map<String, int>? dailyViews,
    Map<String, int>? dailyDownloads,
    Map<String, int>? deviceInfo,
    Map<String, int>? locationStats,
  }) {
    return PrivateStats(
      dailyViews: dailyViews ?? this.dailyViews,
      dailyDownloads: dailyDownloads ?? this.dailyDownloads,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      locationStats: locationStats ?? this.locationStats,
    );
  }

  int get totalPrivateViews {
    return dailyViews.values.fold(0, (sum, count) => sum + count);
  }

  int get totalPrivateDownloads {
    return dailyDownloads.values.fold(0, (sum, count) => sum + count);
  }

  Map<String, int> get topLocations {
    final sorted = Map.fromEntries(
      locationStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  Map<String, int> get topDevices {
    final sorted = Map.fromEntries(
      deviceInfo.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR product_model.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   test('ProductModel creates correctly', () {
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       thumbnail: 'test.jpg',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
     );

     expect(product.id, 'test_1');
     expect(product.title, 'Test Product');
     expect(product.category, 'wallpaper');
     expect(product.isValid, true);
   });

   test('ProductModel getters work correctly', () {
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       thumbnail: 'test.jpg',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       likes: 10,
       views: 100,
       downloads: 50,
       rating: 4.5,
       ratingCount: 20,
     );

     expect(product.categoryDisplayName, 'Wallpaper');
     expect(product.categoryEmoji, '🖼️');
     expect(product.ratingDisplay, '4.5 ⭐ (20)');
   });

   test('ProductModel matchesSearch works', () {
     final product = ProductModel(
       id: 'test_1',
       title: 'Sunset Wallpaper',
       description: 'Beautiful sunset',
       category: 'wallpaper',
       thumbnail: 'test.jpg',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       tags: ['nature', 'sunset'],
     );

     expect(product.matchesSearch('sunset'), true);
     expect(product.matchesSearch('nature'), true);
     expect(product.matchesSearch('beautiful'), true);
     expect(product.matchesSearch('mountain'), false);
   });

   test('ProductModel copyWith works', () {
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       thumbnail: 'test.jpg',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
     );

     final updated = product.copyWith(
       title: 'New Title',
       likes: 5,
     );

     expect(updated.title, 'New Title');
     expect(updated.likes, 5);
     expect(updated.id, 'test_1');
   });

   test('PrivateStats works correctly', () {
     final stats = PrivateStats(
       dailyViews: {'2024-01-01': 10, '2024-01-02': 20},
       dailyDownloads: {'2024-01-01': 5, '2024-01-02': 8},
     );

     expect(stats.totalPrivateViews, 30);
     expect(stats.totalPrivateDownloads, 13);
   });
 }
*/
