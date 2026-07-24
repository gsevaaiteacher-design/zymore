// ============================================================
// 📁 FILE: cart_provider.dart
// 📍 LOCATION: lib/providers/cart_provider.dart
// 🎯 PURPOSE: Cart & Wishlist State Management
// 🔗 USED BY: Product Detail, Cart Screen, Wishlist Screen
// 📝 DESCRIPTION:
//    This file manages cart and wishlist state:
//    - Add/Remove from cart
//    - Add/Remove from wishlist
//    - Cart item management
//    - Quantity updates
//    - Cart total calculation
//    - Local persistence
//    - Clear cart
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ============================================================
// 📁 IMPORT MODELS
// ============================================================
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

// ============================================================
// 🎯 CART PROVIDER - State Management
// ============================================================

class CartProvider extends ChangeNotifier {
  // ── DEPENDENCIES ──
  final SharedPreferences _prefs;

  // ── STATE ──
  List<CartItemModel> _cartItems = [];
  List<String> _wishlistIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── EVENT LISTENERS (Z-FIXER) ──
  final List<Function(String, dynamic)> _cartListeners = [];

  // ── CONSTRUCTOR ──
  CartProvider({SharedPreferences? prefs})
    : _prefs = prefs ?? (throw Exception('SharedPreferences required')) {
    _loadCartFromStorage();
    _loadWishlistFromStorage();
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  List<CartItemModel> get cartItems => _cartItems;
  List<String> get wishlistIds => _wishlistIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  bool get isCartEmpty => _cartItems.isEmpty;
  bool get isWishlistEmpty => _wishlistIds.isEmpty;

  // ============================================================
  // 🛒 CART OPERATIONS
  // ============================================================

  /// Add product to cart
  Future<bool> addToCart(ProductModel product, {int quantity = 1}) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Check if already in cart
      final existingIndex = _cartItems.indexWhere(
        (item) => item.productId == product.id,
      );

      if (existingIndex != -1) {
        // Update quantity
        _cartItems[existingIndex].quantity += quantity;
      } else {
        // Add new item
        _cartItems.add(
          CartItemModel(
            productId: product.id,
            productTitle: product.title,
            productThumbnail: product.thumbnail,
            price: 0.0, // Free marketplace
            quantity: quantity,
            sellerId: product.sellerId,
            sellerName: product.sellerName,
          ),
        );
      }

      // Save to storage
      await _saveCartToStorage();

      _emitCartEvent('cart.item.added', {
        'productId': product.id,
        'quantity': quantity,
        'totalItems': cartCount,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Add to Cart Error: $e');
      _setError('Failed to add to cart');
      _isLoading = false;
      _emitCartEvent('cart.error', {'error': e.toString()});
      return false;
    }
  }

  /// Remove product from cart
  Future<bool> removeFromCart(String productId) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _cartItems.removeWhere((item) => item.productId == productId);
      await _saveCartToStorage();

      _emitCartEvent('cart.item.removed', {
        'productId': productId,
        'totalItems': cartCount,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Remove from Cart Error: $e');
      _setError('Failed to remove from cart');
      _isLoading = false;
      return false;
    }
  }

  /// Update quantity of cart item
  Future<bool> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      return await removeFromCart(productId);
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final index = _cartItems.indexWhere(
        (item) => item.productId == productId,
      );
      if (index == -1) {
        _isLoading = false;
        return false;
      }

      _cartItems[index].quantity = quantity;
      await _saveCartToStorage();

      _emitCartEvent('cart.quantity.updated', {
        'productId': productId,
        'quantity': quantity,
        'totalItems': cartCount,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Update Quantity Error: $e');
      _setError('Failed to update quantity');
      _isLoading = false;
      return false;
    }
  }

  /// Clear cart
  Future<bool> clearCart() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _cartItems.clear();
      await _saveCartToStorage();

      _emitCartEvent('cart.cleared', {'totalItems': 0});

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Clear Cart Error: $e');
      _setError('Failed to clear cart');
      _isLoading = false;
      return false;
    }
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  /// Get cart item by product ID
  CartItemModel? getCartItem(String productId) {
    try {
      final index = _cartItems.indexWhere(
        (item) => item.productId == productId,
      );
      if (index == -1) return null;
      return _cartItems[index];
    } catch (e) {
      return null;
    }
  }

  /// Get quantity of product in cart
  int getQuantity(String productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  // ============================================================
  // ❤️ WISHLIST OPERATIONS
  // ============================================================

  /// Add to wishlist
  Future<bool> addToWishlist(String productId) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      if (_wishlistIds.contains(productId)) {
        _isLoading = false;
        return false;
      }

      _wishlistIds.add(productId);
      await _saveWishlistToStorage();

      _emitCartEvent('wishlist.item.added', {
        'productId': productId,
        'totalItems': _wishlistIds.length,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Add to Wishlist Error: $e');
      _setError('Failed to add to wishlist');
      _isLoading = false;
      return false;
    }
  }

  /// Remove from wishlist
  Future<bool> removeFromWishlist(String productId) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _wishlistIds.remove(productId);
      await _saveWishlistToStorage();

      _emitCartEvent('wishlist.item.removed', {
        'productId': productId,
        'totalItems': _wishlistIds.length,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Remove from Wishlist Error: $e');
      _setError('Failed to remove from wishlist');
      _isLoading = false;
      return false;
    }
  }

  /// Toggle wishlist status
  Future<bool> toggleWishlist(String productId) async {
    if (_wishlistIds.contains(productId)) {
      return await removeFromWishlist(productId);
    } else {
      return await addToWishlist(productId);
    }
  }

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  /// Clear wishlist
  Future<bool> clearWishlist() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _wishlistIds.clear();
      await _saveWishlistToStorage();

      _emitCartEvent('wishlist.cleared', {'totalItems': 0});

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Clear Wishlist Error: $e');
      _setError('Failed to clear wishlist');
      _isLoading = false;
      return false;
    }
  }

  // ============================================================
  // 💾 STORAGE OPERATIONS
  // ============================================================

  Future<void> _saveCartToStorage() async {
    try {
      final jsonList = _cartItems.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString('cart_items', jsonString);
    } catch (e) {
      print('❌ Save Cart Error: $e');
    }
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final jsonString = _prefs.getString('cart_items');
      if (jsonString == null || jsonString.isEmpty) {
        _cartItems = [];
        return;
      }

      final jsonList = jsonDecode(jsonString) as List;
      _cartItems = jsonList
          .map((json) => CartItemModel.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      print('❌ Load Cart Error: $e');
      _cartItems = [];
    }
  }

  Future<void> _saveWishlistToStorage() async {
    try {
      final jsonString = jsonEncode(_wishlistIds);
      await _prefs.setString('wishlist_items', jsonString);
    } catch (e) {
      print('❌ Save Wishlist Error: $e');
    }
  }

  Future<void> _loadWishlistFromStorage() async {
    try {
      final jsonString = _prefs.getString('wishlist_items');
      if (jsonString == null || jsonString.isEmpty) {
        _wishlistIds = [];
        return;
      }

      final jsonList = jsonDecode(jsonString) as List;
      _wishlistIds = jsonList.map((item) => item.toString()).toList();
      notifyListeners();
    } catch (e) {
      print('❌ Load Wishlist Error: $e');
      _wishlistIds = [];
    }
  }

  // ============================================================
  // 📊 SYNC WITH PRODUCTS
  // ============================================================

  /// Sync cart with product list (remove invalid products)
  void syncWithProducts(List<ProductModel> products) {
    final productIds = products.map((p) => p.id).toSet();
    _cartItems.removeWhere((item) => !productIds.contains(item.productId));
    _saveCartToStorage();
    notifyListeners();
  }

  /// Get products from wishlist IDs
  List<ProductModel> getWishlistProducts(List<ProductModel> allProducts) {
    return allProducts
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
  }

  /// Get cart items with product details
  List<Map<String, dynamic>> getCartItemsWithDetails(
    List<ProductModel> allProducts,
  ) {
    final Map<String, ProductModel> productMap = {
      for (var product in allProducts) product.id: product,
    };

    return _cartItems.map((cartItem) {
      final product = productMap[cartItem.productId];
      return {'cartItem': cartItem, 'product': product};
    }).toList();
  }

  // ============================================================
  // 📝 ERROR HANDLING
  // ============================================================

  void _setError(String message) {
    _errorMessage = message;
    _emitCartEvent('cart.error', {'message': message});
  }

  void _clearError() {
    _errorMessage = null;
  }

  // ============================================================
  // 🔔 EVENT EMISSION (Z-FIXER)
  // ============================================================

  void _emitCartEvent(String eventType, dynamic data) {
    for (var listener in _cartListeners) {
      try {
        listener(eventType, data);
      } catch (e) {
        print('❌ Cart listener error: $e');
      }
    }
  }

  void addCartListener(Function(String, dynamic) listener) {
    _cartListeners.add(listener);
  }

  void removeCartListener(Function(String, dynamic) listener) {
    _cartListeners.remove(listener);
  }

  // ============================================================
  // 📊 STATISTICS
  // ============================================================

  Map<String, dynamic> getStats() {
    return {
      'cartItems': _cartItems.length,
      'cartTotalItems': cartCount,
      'cartTotalValue': cartTotal,
      'wishlistItems': _wishlistIds.length,
      'isCartEmpty': isCartEmpty,
      'isWishlistEmpty': isWishlistEmpty,
      'listeners': _cartListeners.length,
    };
  }

  // ============================================================
  // 🧹 CLEANUP
  // ============================================================

  @override
  void dispose() {
    _cartListeners.clear();
    super.dispose();
  }
}

// ============================================================
// 📦 CART ITEM MODEL
// ============================================================

class CartItemModel {
  String productId;
  String productTitle;
  String productThumbnail;
  double price;
  int quantity;
  String sellerId;
  String sellerName;

  CartItemModel({
    required this.productId,
    required this.productTitle,
    required this.productThumbnail,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'productThumbnail': productThumbnail,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productThumbnail: json['productThumbnail'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
    );
  }

  CartItemModel copyWith({
    String? productId,
    String? productTitle,
    String? productThumbnail,
    double? price,
    int? quantity,
    String? sellerId,
    String? sellerName,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productThumbnail: productThumbnail ?? this.productThumbnail,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR cart_provider.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:shared_preferences/shared_preferences.dart';

 void main() {
   setUp(() async {
     SharedPreferences.setMockInitialValues({});
   });

   test('CartProvider initializes correctly', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     expect(provider.cartItems, isEmpty);
     expect(provider.wishlistIds, isEmpty);
     expect(provider.cartCount, 0);
     expect(provider.cartTotal, 0.0);
     expect(provider.isCartEmpty, true);
     expect(provider.isWishlistEmpty, true);
   });

   test('CartProvider adds to cart correctly', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       images: [],
       thumbnail: '',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       createdAt: DateTime.now(),
     );
     
     await provider.addToCart(product);
     expect(provider.cartCount, 1);
     expect(provider.isCartEmpty, false);
   });

   test('CartProvider removes from cart correctly', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       images: [],
       thumbnail: '',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       createdAt: DateTime.now(),
     );
     
     await provider.addToCart(product);
     expect(provider.cartCount, 1);
     
     await provider.removeFromCart('test_1');
     expect(provider.cartCount, 0);
     expect(provider.isCartEmpty, true);
   });

   test('CartProvider updates quantity correctly', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       images: [],
       thumbnail: '',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       createdAt: DateTime.now(),
     );
     
     await provider.addToCart(product, quantity: 2);
     expect(provider.cartCount, 2);
     
     await provider.updateQuantity('test_1', 5);
     expect(provider.cartCount, 5);
   });

   test('CartProvider wishlist operations work', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     await provider.addToWishlist('test_1');
     expect(provider.isInWishlist('test_1'), true);
     expect(provider.wishlistIds.length, 1);
     
     await provider.removeFromWishlist('test_1');
     expect(provider.isInWishlist('test_1'), false);
     expect(provider.wishlistIds.length, 0);
   });

   test('CartProvider toggle wishlist works', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     await provider.toggleWishlist('test_1');
     expect(provider.isInWishlist('test_1'), true);
     
     await provider.toggleWishlist('test_1');
     expect(provider.isInWishlist('test_1'), false);
   });

   test('CartProvider clear cart works', () async {
     final prefs = await SharedPreferences.getInstance();
     final provider = CartProvider(prefs: prefs);
     
     final product = ProductModel(
       id: 'test_1',
       title: 'Test Product',
       description: 'Test Description',
       category: 'wallpaper',
       images: [],
       thumbnail: '',
       sellerId: 'seller_1',
       sellerName: 'Test Seller',
       createdAt: DateTime.now(),
     );
     
     await provider.addToCart(product);
     expect(provider.cartCount, 1);
     
     await provider.clearCart();
     expect(provider.cartCount, 0);
     expect(provider.isCartEmpty, true);
   });
 }
*/
