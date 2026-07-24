// ============================================================
// 📁 FILE: category_model.dart
// 📍 LOCATION: lib/models/category_model.dart
// 🎯 PURPOSE: Category Data Model
// 🔗 USED BY: Product Provider, Home Screen, Category Screen
// 📝 DESCRIPTION:
//    This file defines the Category data model with:
//    - Category basic information
//    - Icon and color
//    - Product count and statistics
//    - Display order
//    - Firestore serialization
//    - JSON serialization
//    - Validation methods
//    - Category presets
//
//    Z-FIXER COMPLIANT:
//    - Contract-first design
//    - Complete error handling
//    - Immutable where possible
//    - Telemetry ready
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ============================================================
// 📂 CATEGORY MODEL
// ============================================================

class CategoryModel {
  // ── BASIC INFO ──
  final String id;
  final String name;
  final String slug;
  final String description;

  // ── VISUAL ──
  final String icon;
  final String color;
  final String? imageUrl;

  // ── ORDERING ──
  final int displayOrder;

  // ── STATS ──
  final int productCount;

  // ── STATUS ──
  final bool isActive;
  final bool isFeatured;

  // ── DATES ──
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── LOCAL STATE (Not stored) ──
  bool isSelected;

  // ============================================================
  // 🏗️ CONSTRUCTORS
  // ============================================================

  CategoryModel({
    required this.id,
    required this.name,
    String? slug,
    this.description = '',
    required this.icon,
    this.color = '#FF6B35',
    this.imageUrl,
    this.displayOrder = 0,
    this.productCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    DateTime? createdAt,
    this.updatedAt,
    this.isSelected = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       slug = (slug != null && slug.isNotEmpty) ? slug : _generateSlug(name);

  // ── FROM FIRESTORE ──
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '📁',
      color: data['color'] ?? '#FF6B35',
      imageUrl: data['imageUrl'],
      displayOrder: data['displayOrder'] ?? 0,
      productCount: data['productCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isSelected: false,
    );
  }

  // ── FROM JSON ──
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '📁',
      color: json['color'] ?? '#FF6B35',
      imageUrl: json['imageUrl'],
      displayOrder: json['displayOrder'] ?? 0,
      productCount: json['productCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isSelected: json['isSelected'] ?? false,
    );
  }

  // ── PRESET CATEGORIES ──
  static List<CategoryModel> getPresetCategories() {
    return [
      CategoryModel(
        id: 'wallpaper',
        name: 'Wallpaper',
        icon: '🖼️',
        color: '#FF6B35',
        displayOrder: 0,
        isFeatured: true,
        description: 'Beautiful wallpapers for your device',
      ),
      CategoryModel(
        id: 'icon',
        name: 'Icon',
        icon: '🎯',
        color: '#00D4FF',
        displayOrder: 1,
        isFeatured: true,
        description: 'Custom icon packs and designs',
      ),
      CategoryModel(
        id: 'art',
        name: 'Art',
        icon: '🎨',
        color: '#9B59B6',
        displayOrder: 2,
        isFeatured: true,
        description: 'Digital art and illustrations',
      ),
      CategoryModel(
        id: 'asset',
        name: 'Asset',
        icon: '📦',
        color: '#2ECC71',
        displayOrder: 3,
        isFeatured: true,
        description: 'Game assets and 3D models',
      ),
    ];
  }

  // ── PRESET CATEGORIES AS MAP ──
  static Map<String, CategoryModel> getPresetCategoryMap() {
    final categories = getPresetCategories();
    return {for (var c in categories) c.id: c};
  }

  // ============================================================
  // 🔄 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'color': color,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'productCount': productCount,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ============================================================
  // 📋 TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'color': color,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'productCount': productCount,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSelected': isSelected,
    };
  }

  // ============================================================
  // 📋 COPY WITH
  // ============================================================

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? icon,
    String? color,
    String? imageUrl,
    int? displayOrder,
    int? productCount,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        icon.isNotEmpty &&
        color.isNotEmpty;
  }

  bool get isComplete {
    return isValid && slug.isNotEmpty && description.isNotEmpty;
  }

  bool get hasImage {
    return imageUrl != null && imageUrl!.isNotEmpty;
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  Color get colorValue {
    try {
      final hex = color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFFFF6B35);
    }
  }

  String get displayName {
    return name;
  }

  String get productCountDisplay {
    if (productCount == 0) return 'No products';
    if (productCount == 1) return '1 product';
    return '$productCount products';
  }

  bool get isPopular {
    return productCount > 100;
  }

  bool get isTrending {
    return productCount > 50 && productCount <= 100;
  }

  // ============================================================
  // 🔍 HELPER METHODS
  // ============================================================

  static String _generateSlug(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        slug.contains(lowerQuery);
  }

  // ============================================================
  // 📝 STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 📊 CATEGORY STATS
// ============================================================

class CategoryStats {
  final int totalCategories;
  final int activeCategories;
  final int featuredCategories;
  final int totalProducts;
  final Map<String, int> productCountByCategory;

  CategoryStats({
    this.totalCategories = 0,
    this.activeCategories = 0,
    this.featuredCategories = 0,
    this.totalProducts = 0,
    this.productCountByCategory = const {},
  });

  factory CategoryStats.fromCategories(List<CategoryModel> categories) {
    int total = categories.length;
    int active = categories.where((c) => c.isActive).length;
    int featured = categories.where((c) => c.isFeatured).length;
    int products = categories.fold(0, (sum, c) => sum + c.productCount);

    Map<String, int> productCount = {};
    for (var category in categories) {
      productCount[category.id] = category.productCount;
    }

    return CategoryStats(
      totalCategories: total,
      activeCategories: active,
      featuredCategories: featured,
      totalProducts: products,
      productCountByCategory: productCount,
    );
  }

  CategoryModel? getMostPopularCategory(List<CategoryModel> categories) {
    if (categories.isEmpty) return null;
    return categories.reduce((a, b) => a.productCount > b.productCount ? a : b);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCategories': totalCategories,
      'activeCategories': activeCategories,
      'featuredCategories': featuredCategories,
      'totalProducts': totalProducts,
      'productCountByCategory': productCountByCategory,
    };
  }

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      totalCategories: json['totalCategories'] ?? 0,
      activeCategories: json['activeCategories'] ?? 0,
      featuredCategories: json['featuredCategories'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      productCountByCategory: Map<String, int>.from(
        json['productCountByCategory'] ?? {},
      ),
    );
  }
}

// ============================================================
// 📂 CATEGORY FILTER
// ============================================================

class CategoryFilter {
  final String? searchQuery;
  final bool showActive;
  final bool showFeatured;
  final String? sortBy;

  CategoryFilter({
    this.searchQuery,
    this.showActive = true,
    this.showFeatured = false,
    this.sortBy,
  });

  List<CategoryModel> apply(List<CategoryModel> categories) {
    List<CategoryModel> result = List.from(categories);

    // Filter by active
    if (showActive) {
      result = result.where((c) => c.isActive).toList();
    }

    // Filter by featured
    if (showFeatured) {
      result = result.where((c) => c.isFeatured).toList();
    }

    // Filter by search
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      result = result.where((c) => c.matchesSearch(searchQuery!)).toList();
    }

    // Sort
    if (sortBy == 'displayOrder') {
      result.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    } else if (sortBy == 'productCount') {
      result.sort((a, b) => b.productCount.compareTo(a.productCount));
    } else if (sortBy == 'name') {
      result.sort((a, b) => a.name.compareTo(b.name));
    }

    return result;
  }

  CategoryFilter copyWith({
    String? searchQuery,
    bool? showActive,
    bool? showFeatured,
    String? sortBy,
  }) {
    return CategoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      showActive: showActive ?? this.showActive,
      showFeatured: showFeatured ?? this.showFeatured,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR category_model.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   test('CategoryModel creates correctly', () {
     final category = CategoryModel(
       id: 'test_1',
       name: 'Test Category',
       icon: '📁',
       color: '#FF6B35',
     );

     expect(category.id, 'test_1');
     expect(category.name, 'Test Category');
     expect(category.slug, 'test-category');
     expect(category.isValid, true);
   });

   test('CategoryModel getters work correctly', () {
     final category = CategoryModel(
       id: 'test_1',
       name: 'Wallpaper',
       icon: '🖼️',
       color: '#FF6B35',
       productCount: 150,
     );

     expect(category.colorValue, const Color(0xFFFF6B35));
     expect(category.displayName, 'Wallpaper');
     expect(category.productCountDisplay, '150 products');
     expect(category.isPopular, true);
   });

   test('CategoryModel preset categories work', () {
     final presets = CategoryModel.getPresetCategories();
     expect(presets.length, 4);
     expect(presets[0].id, 'wallpaper');
     expect(presets[0].name, 'Wallpaper');
     expect(presets[0].icon, '🖼️');
   });

   test('CategoryModel matchesSearch works', () {
     final category = CategoryModel(
       id: 'test_1',
       name: 'Wallpaper',
       icon: '🖼️',
       color: '#FF6B35',
       description: 'Beautiful wallpapers',
     );

     expect(category.matchesSearch('wallpaper'), true);
     expect(category.matchesSearch('beautiful'), true);
     expect(category.matchesSearch('icons'), false);
   });

   test('CategoryStats calculates correctly', () {
     final categories = [
       CategoryModel(
         id: 'c1', name: 'C1', icon: '📁', color: '#000',
         productCount: 10, isActive: true, isFeatured: true,
       ),
       CategoryModel(
         id: 'c2', name: 'C2', icon: '📁', color: '#000',
         productCount: 20, isActive: true, isFeatured: false,
       ),
       CategoryModel(
         id: 'c3', name: 'C3', icon: '📁', color: '#000',
         productCount: 30, isActive: false, isFeatured: false,
       ),
     ];

     final stats = CategoryStats.fromCategories(categories);
     expect(stats.totalCategories, 3);
     expect(stats.activeCategories, 2);
     expect(stats.featuredCategories, 1);
     expect(stats.totalProducts, 60);
   });

   test('CategoryFilter applies correctly', () {
     final categories = [
       CategoryModel(
         id: 'c1', name: 'Wallpaper', icon: '📁', color: '#000',
         productCount: 10, isActive: true, isFeatured: true,
         displayOrder: 1,
       ),
       CategoryModel(
         id: 'c2', name: 'Icons', icon: '📁', color: '#000',
         productCount: 20, isActive: true, isFeatured: false,
         displayOrder: 2,
       ),
       CategoryModel(
         id: 'c3', name: 'Art', icon: '📁', color: '#000',
         productCount: 30, isActive: false, isFeatured: false,
         displayOrder: 3,
       ),
     ];

     final filter = CategoryFilter(showActive: true);
     final result = filter.apply(categories);
     expect(result.length, 2);
     expect(result[0].name, 'Wallpaper');
     expect(result[1].name, 'Icons');
   });
 }
*/
