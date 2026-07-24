// ============================================================
// 📁 FILE: cart_item_model.dart
// 📍 LOCATION: lib/models/cart_item_model.dart
// 🎯 PURPOSE: Cart Item Data Model
// 🔗 USED BY: Cart Provider, Product Detail, Cart Screen
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
