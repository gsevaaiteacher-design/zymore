// ============================================================
// 📁 FILE: review_model.dart
// 📍 LOCATION: lib/models/review_model.dart
// 🎯 PURPOSE: Review Data Model
// 🔗 USED BY: Product Detail Screen, Review Provider
// 📝 DESCRIPTION:
//    This file defines the Review data model with:
//    - Review basic information
//    - User information
//    - Rating (1-5 stars)
//    - Comment and replies
//    - Like functionality
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
// ⭐ REVIEW MODEL
// ============================================================

class ReviewModel {
  // ── BASIC INFO ──
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userPhoto;

  // ── RATING & COMMENT ──
  final int rating;
  final String comment;

  // ── DATES ──
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── STATUS ──
  final bool isVerifiedPurchase;
  final bool isActive;
  final bool isHelpful;

  // ── INTERACTION ──
  final int likes;
  final List<ReplyModel> replies;

  // ── LOCAL STATE (Not stored) ──
  bool isLiked;

  // ============================================================
  // 🏗️ CONSTRUCTORS
  // ============================================================

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.rating,
    required this.comment,
    DateTime? createdAt,
    this.updatedAt,
    this.isVerifiedPurchase = false,
    this.isActive = true,
    this.isHelpful = false,
    this.likes = 0,
    this.replies = const [],
    this.isLiked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── FROM FIRESTORE ──
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ReviewModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
      isActive: data['isActive'] ?? true,
      isHelpful: data['isHelpful'] ?? false,
      likes: data['likes'] ?? 0,
      replies:
          (data['replies'] as List?)
              ?.map((reply) => ReplyModel.fromMap(reply))
              .toList() ??
          [],
      isLiked: false,
    );
  }

  // ── EMPTY REVIEW ──
  factory ReviewModel.empty() {
    return ReviewModel(
      id: '',
      productId: '',
      userId: '',
      userName: '',
      rating: 0,
      comment: '',
    );
  }

  // ── FROM JSON ──
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhoto: json['userPhoto'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      isActive: json['isActive'] ?? true,
      isHelpful: json['isHelpful'] ?? false,
      likes: json['likes'] ?? 0,
      replies:
          (json['replies'] as List?)
              ?.map((reply) => ReplyModel.fromJson(reply))
              .toList() ??
          [],
      isLiked: json['isLiked'] ?? false,
    );
  }

  // ============================================================
  // 🔄 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isVerifiedPurchase': isVerifiedPurchase,
      'isActive': isActive,
      'isHelpful': isHelpful,
      'likes': likes,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  // ============================================================
  // 📋 TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'isActive': isActive,
      'isHelpful': isHelpful,
      'likes': likes,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'isLiked': isLiked,
    };
  }

  // ============================================================
  // 📋 COPY WITH
  // ============================================================

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userPhoto,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerifiedPurchase,
    bool? isActive,
    bool? isHelpful,
    int? likes,
    List<ReplyModel>? replies,
    bool? isLiked,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      isActive: isActive ?? this.isActive,
      isHelpful: isHelpful ?? this.isHelpful,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool get isValid {
    return id.isNotEmpty &&
        productId.isNotEmpty &&
        userId.isNotEmpty &&
        userName.isNotEmpty &&
        rating >= 1 &&
        rating <= 5 &&
        comment.isNotEmpty;
  }

  bool get hasPhoto {
    return userPhoto.isNotEmpty;
  }

  bool get canReply {
    return isActive && comment.isNotEmpty;
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  String get ratingDisplay {
    return '$rating ⭐';
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

  String get shortComment {
    if (comment.length <= 100) return comment;
    return '${comment.substring(0, 100)}...';
  }

  int get replyCount {
    return replies.length;
  }

  // ============================================================
  // 🔍 HELPER METHODS
  // ============================================================

  bool isOwner(String userId) {
    return this.userId == userId;
  }

  bool containsKeyword(String keyword) {
    return comment.toLowerCase().contains(keyword.toLowerCase());
  }

  List<ReplyModel> getTopReplies({int limit = 3}) {
    final sorted = List<ReplyModel>.from(replies)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  // ============================================================
  // 📝 STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'ReviewModel(id: $id, productId: $productId, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 💬 REPLY MODEL
// ============================================================

class ReplyModel {
  // ── BASIC INFO ──
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;

  // ── CONTENT ──
  final String comment;

  // ── DATES ──
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── STATUS ──
  final bool isActive;

  // ============================================================
  // 🏗️ CONSTRUCTORS
  // ============================================================

  ReplyModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.comment,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── FROM MAP ──
  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    return ReplyModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhoto: map['userPhoto'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // ── FROM JSON ──
  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhoto: json['userPhoto'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  // ============================================================
  // 🔄 TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  // ============================================================
  // 📋 TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // ============================================================
  // 📋 COPY WITH
  // ============================================================

  ReplyModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ReplyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool get isValid {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        userName.isNotEmpty &&
        comment.isNotEmpty;
  }

  bool get hasPhoto {
    return userPhoto.isNotEmpty;
  }

  bool isOwner(String userId) {
    return this.userId == userId;
  }

  // ============================================================
  // 📝 STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'ReplyModel(id: $id, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReplyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 📊 REVIEW STATS
// ============================================================

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;

  ReviewStats({
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
  });

  factory ReviewStats.fromReviews(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return ReviewStats();
    }

    final total = reviews.length;
    final sum = reviews.fold(0, (sum, review) => sum + review.rating);
    final avg = sum / total;

    int fiveStar = 0;
    int fourStar = 0;
    int threeStar = 0;
    int twoStar = 0;
    int oneStar = 0;

    for (var review in reviews) {
      switch (review.rating) {
        case 5:
          fiveStar++;
          break;
        case 4:
          fourStar++;
          break;
        case 3:
          threeStar++;
          break;
        case 2:
          twoStar++;
          break;
        case 1:
          oneStar++;
          break;
      }
    }

    return ReviewStats(
      averageRating: avg,
      totalReviews: total,
      fiveStarCount: fiveStar,
      fourStarCount: fourStar,
      threeStarCount: threeStar,
      twoStarCount: twoStar,
      oneStarCount: oneStar,
    );
  }

  double get percentageFiveStar {
    if (totalReviews == 0) return 0.0;
    return (fiveStarCount / totalReviews) * 100;
  }

  double get percentageFourStar {
    if (totalReviews == 0) return 0.0;
    return (fourStarCount / totalReviews) * 100;
  }

  double get percentageThreeStar {
    if (totalReviews == 0) return 0.0;
    return (threeStarCount / totalReviews) * 100;
  }

  double get percentageTwoStar {
    if (totalReviews == 0) return 0.0;
    return (twoStarCount / totalReviews) * 100;
  }

  double get percentageOneStar {
    if (totalReviews == 0) return 0.0;
    return (oneStarCount / totalReviews) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'fiveStarCount': fiveStarCount,
      'fourStarCount': fourStarCount,
      'threeStarCount': threeStarCount,
      'twoStarCount': twoStarCount,
      'oneStarCount': oneStarCount,
    };
  }

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      fiveStarCount: json['fiveStarCount'] ?? 0,
      fourStarCount: json['fourStarCount'] ?? 0,
      threeStarCount: json['threeStarCount'] ?? 0,
      twoStarCount: json['twoStarCount'] ?? 0,
      oneStarCount: json['oneStarCount'] ?? 0,
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR review_model.dart

 import 'package:flutter_test/flutter_test.dart';

 void main() {
   test('ReviewModel creates correctly', () {
     final review = ReviewModel(
       id: 'review_1',
       productId: 'product_1',
       userId: 'user_1',
       userName: 'Test User',
       rating: 5,
       comment: 'Amazing product!',
     );

     expect(review.id, 'review_1');
     expect(review.rating, 5);
     expect(review.comment, 'Amazing product!');
     expect(review.isValid, true);
   });

   test('ReviewModel getters work correctly', () {
     final review = ReviewModel(
       id: 'review_1',
       productId: 'product_1',
       userId: 'user_1',
       userName: 'Test User',
       rating: 5,
       comment: 'Amazing product! This is a really long comment...',
       likes: 10,
     );

     expect(review.ratingDisplay, '5 ⭐');
     expect(review.shortComment.length, lessThan(101));
     expect(review.likes, 10);
   });

   test('ReviewModel isOwner works', () {
     final review = ReviewModel(
       id: 'review_1',
       productId: 'product_1',
       userId: 'user_1',
       userName: 'Test User',
       rating: 5,
       comment: 'Amazing product!',
     );

     expect(review.isOwner('user_1'), true);
     expect(review.isOwner('user_2'), false);
   });

   test('ReplyModel creates correctly', () {
     final reply = ReplyModel(
       id: 'reply_1',
       userId: 'user_2',
       userName: 'Reply User',
       comment: 'Thanks for the review!',
     );

     expect(reply.id, 'reply_1');
     expect(reply.comment, 'Thanks for the review!');
     expect(reply.isValid, true);
   });

   test('ReviewStats calculates correctly', () {
     final reviews = [
       ReviewModel(
         id: '1', productId: 'p1', userId: 'u1',
         userName: 'u1', rating: 5, comment: 'Great!',
       ),
       ReviewModel(
         id: '2', productId: 'p1', userId: 'u2',
         userName: 'u2', rating: 4, comment: 'Good!',
       ),
       ReviewModel(
         id: '3', productId: 'p1', userId: 'u3',
         userName: 'u3', rating: 3, comment: 'Okay!',
       ),
     ];

     final stats = ReviewStats.fromReviews(reviews);
     expect(stats.totalReviews, 3);
     expect(stats.averageRating, 4.0);
     expect(stats.fiveStarCount, 1);
     expect(stats.fourStarCount, 1);
     expect(stats.threeStarCount, 1);
   });
 }
*/
