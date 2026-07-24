// ============================================================
// 📁 FILE: product_provider.dart
// 📍 LOCATION: lib/providers/product_provider.dart
// 🎯 PURPOSE: Product State Management Provider
// 🔗 USED BY: Home, Category, Detail, Upload Screens
// 📝 DESCRIPTION:
//    This file manages product state using Provider:
//    - Fetch products from Firestore
//    - Filter by category
//    - Search products
//    - Like/Unlike products
//    - Upload products (Seller)
//    - Product caching
//    - Real-time updates
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// ============================================================
// 📁 IMPORT MODELS & SERVICES
// ============================================================
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';

// ============================================================
// 🎯 PRODUCT PROVIDER - State Management
// ============================================================

class ProductProvider extends ChangeNotifier {
  // ── DEPENDENCIES ──
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── STATE ──
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _userProducts = [];
  List<ProductModel> _likedProducts = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _currentCategory;
  String? _searchQuery;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  static const int _pageSize = 20;

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _productListeners = [];

  // ── CONSTRUCTOR ──
  ProductProvider() {
    _initCategories();
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  List<ProductModel> get products =>
      _filteredProducts.isNotEmpty ? _filteredProducts : _products;

  List<ProductModel> get allProducts => _products;
  List<ProductModel> get userProducts => _userProducts;
  List<ProductModel> get likedProducts => _likedProducts;
  List<CategoryModel> get categories => _categories;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get currentCategory => _currentCategory;
  String? get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;

  // ============================================================
  // 📂 INIT CATEGORIES
  // ============================================================

  Future<void> _initCategories() async {
    try {
      // Default categories
      _categories = [
        CategoryModel(
          id: 'wallpaper',
          name: 'Wallpaper',
          icon: '🖼️',
          color: '#FF6B35',
          displayOrder: 0,
        ),
        CategoryModel(
          id: 'icon',
          name: 'Icon',
          icon: '🎯',
          color: '#00D4FF',
          displayOrder: 1,
        ),
        CategoryModel(
          id: 'art',
          name: 'Art',
          icon: '🎨',
          color: '#9B59B6',
          displayOrder: 2,
        ),
        CategoryModel(
          id: 'asset',
          name: 'Asset',
          icon: '📦',
          color: '#2ECC71',
          displayOrder: 3,
        ),
      ];
      notifyListeners();
    } catch (e) {
      print('❌ Init Categories Error: $e');
    }
  }

  // ============================================================
  // 📦 PRODUCT CRUD OPERATIONS
  // ============================================================

  /// Fetch products from Firestore with pagination
  Future<void> fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _products.clear();
      _filteredProducts.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;

      // Build query
      Query query = _firestore
          .collection(AppConstants.collectionProducts)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastDocument != null && !refresh) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();

      // Update pagination
      if (snapshot.docs.length < _pageSize) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      // Parse products
      final List<ProductModel> newProducts = [];
      for (var doc in snapshot.docs) {
        try {
          final product = ProductModel.fromFirestore(doc);
          // Check if user has liked this product
          if (userId != null) {
            await _checkIfLiked(product, userId);
          }
          newProducts.add(product);
        } catch (e) {
          print('❌ Parse Product Error: $e');
        }
      }

      if (refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      // Apply filters
      _applyFilters();

      _emitProductEvent('products.fetched', {
        'count': _products.length,
        'hasMore': _hasMore,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch Products Error: $e');
      _setError('Failed to load products');
      _isLoading = false;
      _emitProductEvent('products.fetch.error', {'error': e.toString()});
      notifyListeners();
    }
  }

  /// Fetch products by category
  Future<void> fetchProductsByCategory(String categoryId) async {
    _currentCategory = categoryId;
    _products.clear();
    _filteredProducts.clear();
    _lastDocument = null;
    _hasMore = true;

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;

      Query query = _firestore
          .collection(AppConstants.collectionProducts)
          .where('category', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.length < _pageSize) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      final List<ProductModel> newProducts = [];
      for (var doc in snapshot.docs) {
        try {
          final product = ProductModel.fromFirestore(doc);
          if (userId != null) {
            await _checkIfLiked(product, userId);
          }
          newProducts.add(product);
        } catch (e) {
          print('❌ Parse Product Error: $e');
        }
      }

      _products = newProducts;
      _applyFilters();

      _emitProductEvent('products.category.fetched', {
        'category': categoryId,
        'count': _products.length,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch Products By Category Error: $e');
      _setError('Failed to load products');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch user's uploaded products
  Future<void> fetchUserProducts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.collectionProducts)
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userProducts = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc);
      }).toList();

      _emitProductEvent('user.products.fetched', {
        'count': _userProducts.length,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch User Products Error: $e');
      _setError('Failed to load your products');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch liked products
  Future<void> fetchLikedProducts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // First get all liked product IDs
      final QuerySnapshot likeSnapshot = await _firestore
          .collection(AppConstants.collectionLikes)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final List<String> productIds = likeSnapshot.docs
          .map((doc) => doc['productId'] as String)
          .toList();

      if (productIds.isEmpty) {
        _likedProducts = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Then fetch products
      final QuerySnapshot productSnapshot = await _firestore
          .collection(AppConstants.collectionProducts)
          .where('id', whereIn: productIds)
          .where('isActive', isEqualTo: true)
          .get();

      _likedProducts = productSnapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc);
      }).toList();

      // Mark as liked
      for (var product in _likedProducts) {
        product.isLiked = true;
      }

      _emitProductEvent('liked.products.fetched', {
        'count': _likedProducts.length,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch Liked Products Error: $e');
      _setError('Failed to load liked products');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .get();

      if (!doc.exists) return null;

      final product = ProductModel.fromFirestore(doc);

      // Increment view count
      await _incrementViewCount(productId);

      return product;
    } catch (e) {
      print('❌ Get Product Error: $e');
      return null;
    }
  }

  // ============================================================
  // 🔍 SEARCH PRODUCTS
  // ============================================================

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredProducts = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Search by title or tags
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.collectionProducts)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final List<ProductModel> results = [];
      final lowerQuery = query.toLowerCase();

      for (var doc in snapshot.docs) {
        final product = ProductModel.fromFirestore(doc);
        if (product.title.toLowerCase().contains(lowerQuery) ||
            product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
            product.description.toLowerCase().contains(lowerQuery)) {
          results.add(product);
        }
      }

      _filteredProducts = results;

      _emitProductEvent('products.searched', {
        'query': query,
        'results': results.length,
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Search Products Error: $e');
      _setError('Search failed');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ❤️ LIKE/UNLIKE PRODUCTS
  // ============================================================

  Future<bool> toggleLike(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('Please login to like products');
      return false;
    }

    try {
      // Check if already liked
      final QuerySnapshot likeSnapshot = await _firestore
          .collection(AppConstants.collectionLikes)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .get();

      final productIndex = _products.indexWhere((p) => p.id == productId);
      final product = productIndex != -1 ? _products[productIndex] : null;

      if (likeSnapshot.docs.isNotEmpty) {
        // Unlike: Delete like
        final likeDoc = likeSnapshot.docs.first;
        await likeDoc.reference.delete();

        // Update product like count
        if (product != null) {
          final updated = product.copyWith(likes: product.likes - 1, isLiked: false);
          _products[productIndex] = updated;
        }

        await _updateProductLikeCount(productId, -1);

        _emitProductEvent('product.unliked', {
          'productId': productId,
          'userId': userId,
        });

        notifyListeners();
        return false;
      } else {
        // Like: Add like
        await _firestore.collection(AppConstants.collectionLikes).add({
          'userId': userId,
          'productId': productId,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        // Update product like count
        if (product != null) {
          final updated = product.copyWith(likes: product.likes + 1, isLiked: true);
          _products[productIndex] = updated;
        }

        await _updateProductLikeCount(productId, 1);

        _emitProductEvent('product.liked', {
          'productId': productId,
          'userId': userId,
        });

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('❌ Toggle Like Error: $e');
      _setError('Failed to update like');
      return false;
    }
  }

  Future<void> _updateProductLikeCount(String productId, int delta) async {
    try {
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .update({'likes': FieldValue.increment(delta)});
    } catch (e) {
      print('❌ Update Like Count Error: $e');
    }
  }

  Future<void> _checkIfLiked(ProductModel product, String userId) async {
    try {
      final QuerySnapshot likeSnapshot = await _firestore
          .collection(AppConstants.collectionLikes)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: product.id)
          .where('isActive', isEqualTo: true)
          .get();

      product.isLiked = likeSnapshot.docs.isNotEmpty;
    } catch (e) {
      product.isLiked = false;
    }
  }

  // ============================================================
  // 👁️ VIEW COUNTS
  // ============================================================

  Future<void> _incrementViewCount(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .update({'views': FieldValue.increment(1)});
    } catch (e) {
      print('❌ Increment View Count Error: $e');
    }
  }

  Future<void> incrementPrivateView(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .update({'privateViews': FieldValue.increment(1)});
    } catch (e) {
      print('❌ Increment Private View Error: $e');
    }
  }

  // ============================================================
  // 📤 UPLOAD PRODUCT (Seller)
  // ============================================================

  Future<bool> uploadProduct(ProductModel product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('Please login to upload');
      return false;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Add seller info
      final user = _auth.currentUser;
      product = product.copyWith(
        sellerId: userId,
        sellerName: user?.displayName ?? 'Anonymous',
        sellerPhoto: user?.photoURL ?? '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection(AppConstants.collectionProducts)
          .add(product.toFirestore());

      product = product.copyWith(id: docRef.id);

      // Add to local list
      _products.insert(0, product);
      _applyFilters();

      _emitProductEvent('product.uploaded', {
        'productId': product.id,
        'title': product.title,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Upload Product Error: $e');
      _setError('Failed to upload product');
      _isLoading = false;
      _emitProductEvent('product.upload.error', {'error': e.toString()});
      return false;
    }
  }

  // ============================================================
  // 🗑️ DELETE PRODUCT
  // ============================================================

  Future<bool> deleteProduct(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('Please login to delete');
      return false;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Delete from Firestore
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .delete();

      // Remove from local lists
      _products.removeWhere((p) => p.id == productId);
      _filteredProducts.removeWhere((p) => p.id == productId);
      _userProducts.removeWhere((p) => p.id == productId);
      _likedProducts.removeWhere((p) => p.id == productId);

      _emitProductEvent('product.deleted', {'productId': productId});

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Delete Product Error: $e');
      _setError('Failed to delete product');
      _isLoading = false;
      return false;
    }
  }

  // ============================================================
  // 🔄 FILTERS & SEARCH
  // ============================================================

  void filterByCategory(String? categoryId) {
    _currentCategory = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _currentCategory = null;
    _searchQuery = null;
    _filteredProducts = [];
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<ProductModel> result = List.from(_products);

    // Apply category filter
    if (_currentCategory != null && _currentCategory!.isNotEmpty) {
      result = result.where((p) => p.category == _currentCategory).toList();
    }

    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.tags.any((tag) => tag.toLowerCase().contains(query)) ||
                p.description.toLowerCase().contains(query),
          )
          .toList();
    }

    _filteredProducts = result;
  }

  // ============================================================
  // 📝 ERROR HANDLING
  // ============================================================

  void _setError(String message) {
    _errorMessage = message;
    _emitProductEvent('product.error', {'message': message});
  }

  void _clearError() {
    _errorMessage = null;
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitProductEvent(String eventType, dynamic data) {
    for (var listener in _productListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Product listener error: $e');
      }
    }
  }

  void addProductListener(Function(String, dynamic) listener) {
    _productListeners.add(listener);
  }

  void removeProductListener(Function(String, dynamic) listener) {
    _productListeners.remove(listener);
  }

  // ============================================================
  // 📊 STATISTICS
  // ============================================================

  Map<String, dynamic> getStats() {
    return {
      'totalProducts': _products.length,
      'filteredProducts': _filteredProducts.length,
      'userProducts': _userProducts.length,
      'likedProducts': _likedProducts.length,
      'categories': _categories.length,
      'hasMore': _hasMore,
      'isLoading': _isLoading,
    };
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  @override
  void dispose() {
    _productListeners.clear();
    super.dispose();
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR product_provider.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   test('ProductProvider initializes correctly', () {
     final provider = ProductProvider();
     expect(provider.products, isNotNull);
     expect(provider.categories.length, 4);
     expect(provider.isLoading, false);
   });

   test('ProductProvider category filters work', () {
     final provider = ProductProvider();
     provider.filterByCategory('wallpaper');
     expect(provider.currentCategory, 'wallpaper');
   });

   test('ProductProvider clear filters works', () {
     final provider = ProductProvider();
     provider.filterByCategory('wallpaper');
     expect(provider.currentCategory, 'wallpaper');
     
     provider.clearFilters();
     expect(provider.currentCategory, null);
   });
 }
*/
