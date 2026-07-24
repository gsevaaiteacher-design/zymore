// ============================================================
// 📁 FILE: database_service.dart
// 📍 LOCATION: lib/services/database_service.dart
// 🎯 PURPOSE: Database Service - Firestore CRUD Operations
// 🔗 USED BY: All Providers, Services, Screens
// 📝 DESCRIPTION:
//    This file handles all Firestore database operations:
//    - Generic CRUD operations
//    - Product operations
//    - User operations
//    - Review operations
//    - Category operations
//    - Download history operations
//    - Like operations
//    - Real-time listeners
//    - Query builders
//    - Batch operations
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// ============================================================
// 📁 IMPORT MODELS & CONSTANTS
// ============================================================
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/category_model.dart';
import '../models/download_history.dart';
import '../utils/constants.dart';

// ============================================================
// 🗄️ DATABASE SERVICE - Singleton
// ============================================================

class DatabaseService {
  // ── SINGLETON ──
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ── FIREBASE INSTANCES ──
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── CACHE ──
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _dbListeners = [];

  // ============================================================
  // 🔧 GENERIC CRUD OPERATIONS
  // ============================================================

  /// Create a document
  Future<String?> createDocument(
    String collection,
    Map<String, dynamic> data, {
    String? documentId,
  }) async {
    try {
      CollectionReference ref = _firestore.collection(collection);
      DocumentReference docRef;

      if (documentId != null) {
        docRef = ref.doc(documentId);
        await docRef.set(data);
      } else {
        docRef = await ref.add(data);
      }

      _emitEvent('db.create', {'collection': collection, 'docId': docRef.id});

      return docRef.id;
    } catch (e) {
      print('❌ Create Document Error: $e');
      _emitEvent('db.error', {'operation': 'create', 'error': e.toString()});
      return null;
    }
  }

  /// Read a document
  Future<Map<String, dynamic>?> readDocument(
    String collection,
    String documentId, {
    bool useCache = true,
  }) async {
    try {
      // Check cache
      if (useCache) {
        final cached = _getFromCache('$collection/$documentId');
        if (cached != null) return cached;
      }

      final doc = await _firestore.collection(collection).doc(documentId).get();

      if (!doc.exists) {
        _emitEvent('db.read.not_found', {
          'collection': collection,
          'docId': documentId,
        });
        return null;
      }

      final data = doc.data()!;

      // Cache result
      if (useCache) {
        _addToCache('$collection/$documentId', data);
      }

      _emitEvent('db.read', {'collection': collection, 'docId': documentId});

      return data;
    } catch (e) {
      print('❌ Read Document Error: $e');
      _emitEvent('db.error', {'operation': 'read', 'error': e.toString()});
      return null;
    }
  }

  /// Update a document
  Future<bool> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);

      // Invalidate cache
      _invalidateCache('$collection/$documentId');

      _emitEvent('db.update', {'collection': collection, 'docId': documentId});

      return true;
    } catch (e) {
      print('❌ Update Document Error: $e');
      _emitEvent('db.error', {'operation': 'update', 'error': e.toString()});
      return false;
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();

      // Invalidate cache
      _invalidateCache('$collection/$documentId');

      _emitEvent('db.delete', {'collection': collection, 'docId': documentId});

      return true;
    } catch (e) {
      print('❌ Delete Document Error: $e');
      _emitEvent('db.error', {'operation': 'delete', 'error': e.toString()});
      return false;
    }
  }

  /// Get all documents from a collection
  Future<List<Map<String, dynamic>>> getDocuments(
    String collection, {
    String? orderBy,
    bool descending = true,
    int? limit,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (var filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _emitEvent('db.get_documents', {
        'collection': collection,
        'count': results.length,
      });

      return results;
    } catch (e) {
      print('❌ Get Documents Error: $e');
      _emitEvent('db.error', {
        'operation': 'get_documents',
        'error': e.toString(),
      });
      return [];
    }
  }

  /// Get documents with pagination
  Future<List<Map<String, dynamic>>> getDocumentsPaginated(
    String collection, {
    String? orderBy,
    bool descending = true,
    int limit = 20,
    DocumentSnapshot? startAfter,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (var filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply startAfter
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Apply limit
      query = query.limit(limit);

      final snapshot = await query.get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _emitEvent('db.get_documents_paginated', {
        'collection': collection,
        'count': results.length,
        'hasMore': snapshot.docs.length == limit,
      });

      return results;
    } catch (e) {
      print('❌ Get Documents Paginated Error: $e');
      _emitEvent('db.error', {
        'operation': 'get_documents_paginated',
        'error': e.toString(),
      });
      return [];
    }
  }

  // ============================================================
  // 📦 PRODUCT OPERATIONS
  // ============================================================

  /// Create a product
  Future<ProductModel?> createProduct(ProductModel product) async {
    try {
      final data = product.toFirestore();
      final id = await createDocument(
        AppConstants.collectionProducts,
        data,
        documentId: product.id.isNotEmpty ? product.id : null,
      );

      if (id == null) return null;

      final createdProduct = product.copyWith(id: id);

      _emitEvent('db.product.created', {
        'productId': id,
        'title': product.title,
      });

      return createdProduct;
    } catch (e) {
      print('❌ Create Product Error: $e');
      _emitEvent('db.error', {
        'operation': 'create_product',
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get a product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final data = await readDocument(
        AppConstants.collectionProducts,
        productId,
      );
      if (data == null) return null;

      final product = ProductModel(
        id: data['id'] ?? productId,
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
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isActive: data['isActive'] ?? true,
        privateViews: data['privateViews'] ?? 0,
        isLiked: false,
      );

      _emitEvent('db.product.get', {'productId': productId});
      return product;
    } catch (e) {
      print('❌ Get Product Error: $e');
      _emitEvent('db.error', {
        'operation': 'get_product',
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get products with filters
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
    String? sellerId,
    bool activeOnly = true,
    String? orderBy = 'createdAt',
    bool descending = true,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      List<QueryFilter> filters = [];

      if (category != null) {
        filters.add(QueryFilter(field: 'category', value: category));
      }
      if (sellerId != null) {
        filters.add(QueryFilter(field: 'sellerId', value: sellerId));
      }
      if (activeOnly) {
        filters.add(QueryFilter(field: 'isActive', value: true));
      }

      final results = await getDocumentsPaginated(
        AppConstants.collectionProducts,
        orderBy: orderBy,
        descending: descending,
        limit: limit ?? 20,
        startAfter: startAfter,
        filters: filters,
      );

      final products = results
          .map(
            (data) => ProductModel(
              id: data['id'] ?? '',
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
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt:
                  (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isActive: data['isActive'] ?? true,
              privateViews: data['privateViews'] ?? 0,
              isLiked: false,
            ),
          )
          .toList();

      _emitEvent('db.products.get', {
        'count': products.length,
        'category': category,
      });

      return products;
    } catch (e) {
      print('❌ Get Products Error: $e');
      _emitEvent('db.error', {
        'operation': 'get_products',
        'error': e.toString(),
      });
      return [];
    }
  }

  /// Update product
  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return await updateDocument(
      AppConstants.collectionProducts,
      productId,
      data,
    );
  }

  /// Delete product
  Future<bool> deleteProduct(String productId) async {
    return await deleteDocument(AppConstants.collectionProducts, productId);
  }

  // ============================================================
  // 👤 USER OPERATIONS
  // ============================================================

  /// Create or update user
  Future<bool> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.id)
          .set(user.toFirestore(), SetOptions(merge: true));

      _emitEvent('db.user.saved', {'userId': user.id});
      return true;
    } catch (e) {
      print('❌ Save User Error: $e');
      _emitEvent('db.error', {'operation': 'save_user', 'error': e.toString()});
      return false;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = await readDocument(AppConstants.collectionUsers, userId);
      if (data == null) return null;

      return UserModel(
        id: data['id'] ?? userId,
        email: data['email'] ?? '',
        displayName: data['displayName'] ?? '',
        photoURL: data['photoURL'] ?? '',
        phoneNumber: data['phoneNumber'],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastLogin:
            (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isSeller: data['isSeller'] ?? false,
        isAdmin: data['isAdmin'] ?? false,
      );
    } catch (e) {
      print('❌ Get User Error: $e');
      _emitEvent('db.error', {'operation': 'get_user', 'error': e.toString()});
      return null;
    }
  }

  /// Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return await updateDocument(AppConstants.collectionUsers, userId, data);
  }

  // ============================================================
  // ⭐ REVIEW OPERATIONS
  // ============================================================

  /// Add review
  Future<bool> addReview(ReviewModel review) async {
    try {
      final id = await createDocument(
        AppConstants.collectionReviews,
        review.toFirestore(),
      );
      if (id == null) return false;

      // Update product rating
      await _updateProductRating(review.productId);

      _emitEvent('db.review.added', {
        'reviewId': id,
        'productId': review.productId,
      });
      return true;
    } catch (e) {
      print('❌ Add Review Error: $e');
      _emitEvent('db.error', {
        'operation': 'add_review',
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get reviews for a product
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final results = await getDocuments(
        AppConstants.collectionReviews,
        orderBy: 'createdAt',
        descending: true,
        filters: [
          QueryFilter(field: 'productId', value: productId),
          QueryFilter(field: 'isActive', value: true),
        ],
      );

      return results
          .map(
            (data) => ReviewModel(
              id: data['id'] ?? '',
              productId: data['productId'] ?? '',
              userId: data['userId'] ?? '',
              userName: data['userName'] ?? '',
              userPhoto: data['userPhoto'] ?? '',
              rating: data['rating'] ?? 0,
              comment: data['comment'] ?? '',
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
              isActive: data['isActive'] ?? true,
              likes: data['likes'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Get Reviews Error: $e');
      _emitEvent('db.error', {
        'operation': 'get_reviews',
        'error': e.toString(),
      });
      return [];
    }
  }

  /// Update product rating
  Future<void> _updateProductRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) return;

      final total = reviews.length;
      final sum = reviews.fold(0, (sum, review) => sum + review.rating);
      final average = sum / total;

      await updateDocument(AppConstants.collectionProducts, productId, {
        'rating': average,
        'ratingCount': total,
      });
    } catch (e) {
      print('❌ Update Product Rating Error: $e');
    }
  }

  // ============================================================
  // ❤️ LIKE OPERATIONS
  // ============================================================

  /// Like a product
  Future<bool> likeProduct(String productId, String userId) async {
    try {
      // Check if already liked
      final existing = await getDocuments(
        AppConstants.collectionLikes,
        filters: [
          QueryFilter(field: 'productId', value: productId),
          QueryFilter(field: 'userId', value: userId),
        ],
      );

      if (existing.isNotEmpty) {
        // Unlike: Delete
        await deleteDocument(
          AppConstants.collectionLikes,
          existing.first['id'],
        );
        await updateProduct(productId, {'likes': FieldValue.increment(-1)});
        _emitEvent('db.like.removed', {'productId': productId});
        return false;
      } else {
        // Like: Add
        await createDocument(AppConstants.collectionLikes, {
          'productId': productId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        await updateProduct(productId, {'likes': FieldValue.increment(1)});
        _emitEvent('db.like.added', {'productId': productId});
        return true;
      }
    } catch (e) {
      print('❌ Like Product Error: $e');
      _emitEvent('db.error', {
        'operation': 'like_product',
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get liked product IDs for a user
  Future<List<String>> getLikedProductIds(String userId) async {
    try {
      final results = await getDocuments(
        AppConstants.collectionLikes,
        filters: [
          QueryFilter(field: 'userId', value: userId),
          QueryFilter(field: 'isActive', value: true),
        ],
      );
      return results.map((data) => data['productId'] as String).toList();
    } catch (e) {
      print('❌ Get Liked Product IDs Error: $e');
      return [];
    }
  }

  // ============================================================
  // 📥 DOWNLOAD HISTORY OPERATIONS
  // ============================================================

  /// Add download history
  Future<bool> addDownloadHistory(DownloadHistory history) async {
    try {
      final id = await createDocument(
        AppConstants.collectionDownloads,
        history.toFirestore(),
      );

      if (id != null) {
        // Increment product downloads
        await updateProduct(history.productId, {
          'downloads': FieldValue.increment(1),
        });
        _emitEvent('db.download.added', {'productId': history.productId});
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Add Download History Error: $e');
      _emitEvent('db.error', {
        'operation': 'add_download_history',
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get download history for a user
  Future<List<DownloadHistory>> getUserDownloadHistory(String userId) async {
    try {
      final results = await getDocuments(
        AppConstants.collectionDownloads,
        orderBy: 'downloadedAt',
        descending: true,
        filters: [QueryFilter(field: 'userId', value: userId)],
      );

      return results
          .map(
            (data) => DownloadHistory(
              id: data['id'] ?? '',
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
              downloadedAt:
                  (data['downloadedAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              localPath: data['localPath'],
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Get User Download History Error: $e');
      _emitEvent('db.error', {
        'operation': 'get_download_history',
        'error': e.toString(),
      });
      return [];
    }
  }

  // ============================================================
  // 🔄 REAL-TIME LISTENERS
  // ============================================================

  /// Listen to products in real-time
  Stream<List<ProductModel>> listenProducts({
    String? category,
    String? sellerId,
    bool activeOnly = true,
  }) {
    try {
      Query query = _firestore.collection(AppConstants.collectionProducts);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
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
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt:
                (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isActive: data['isActive'] ?? true,
            privateViews: data['privateViews'] ?? 0,
            isLiked: false,
          );
        }).toList();
      });
    } catch (e) {
      print('❌ Listen Products Error: $e');
      return Stream.value([]);
    }
  }

  /// Listen to a single product
  Stream<ProductModel?> listenProduct(String productId) {
    try {
      return _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            final data = doc.data()!;
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
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt:
                  (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isActive: data['isActive'] ?? true,
              privateViews: data['privateViews'] ?? 0,
              isLiked: false,
            );
          });
    } catch (e) {
      print('❌ Listen Product Error: $e');
      return Stream.value(null);
    }
  }

  // ============================================================
  // 🗑️ BATCH OPERATIONS
  // ============================================================

  /// Perform batch write
  Future<bool> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (var op in operations) {
        final ref = _firestore.collection(op.collection).doc(op.documentId);

        switch (op.type) {
          case BatchOperationType.set:
            batch.set(ref, op.data!, SetOptions(merge: op.merge ?? false));
            break;
          case BatchOperationType.update:
            batch.update(ref, op.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(ref);
            break;
        }
      }

      await batch.commit();

      _emitEvent('db.batch.committed', {'count': operations.length});
      return true;
    } catch (e) {
      print('❌ Batch Write Error: $e');
      _emitEvent('db.error', {
        'operation': 'batch_write',
        'error': e.toString(),
      });
      return false;
    }
  }

  // ============================================================
  // 💾 CACHE MANAGEMENT
  // ============================================================

  void _addToCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  dynamic _getFromCache(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _invalidateCache(key);
      return null;
    }
    return _cache[key];
  }

  void _invalidateCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitEvent(String eventType, dynamic data) {
    for (var listener in _dbListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ DB listener error: $e');
      }
    }
  }

  void addListener(Function(String, dynamic) listener) {
    _dbListeners.add(listener);
  }

  void removeListener(Function(String, dynamic) listener) {
    _dbListeners.remove(listener);
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  void dispose() {
    _dbListeners.clear();
    clearCache();
  }
}

// ============================================================
// 📊 QUERY FILTER
// ============================================================

class QueryFilter {
  final String field;
  final dynamic value;

  QueryFilter({required this.field, required this.value});
}

// ============================================================
// 🗑️ BATCH OPERATION
// ============================================================

enum BatchOperationType { set, update, delete }

class BatchOperation {
  final String collection;
  final String documentId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;
  final bool? merge;

  BatchOperation.set({
    required this.collection,
    required this.documentId,
    required Map<String, dynamic> data,
    this.merge = true,
  }) : type = BatchOperationType.set,
       data = data;

  BatchOperation.update({
    required this.collection,
    required this.documentId,
    required Map<String, dynamic> data,
  }) : type = BatchOperationType.update,
       data = data,
       merge = null;

  BatchOperation.delete({required this.collection, required this.documentId})
    : type = BatchOperationType.delete,
      data = null,
      merge = null;
}
