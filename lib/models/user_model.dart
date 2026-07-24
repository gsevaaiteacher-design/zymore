// ============================================================
// 📁 FILE: user_model.dart
// 📍 LOCATION: lib/models/user_model.dart
// 🎯 PURPOSE: User Data Model
// 🔗 USED BY: Auth Provider, Profile Screen, All Services
// 📝 DESCRIPTION:
//    This file defines the User data model with:
//    - User authentication fields
//    - User profile fields
//    - Seller-specific fields
//    - Preferences
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
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================
// 👤 USER MODEL
// ============================================================

class UserModel {
  // ── BASIC INFO ──
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final String? phoneNumber;

  // ── DATES ──
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime? updatedAt;

  // ── ROLES ──
  final bool isSeller;
  final bool isAdmin;
  final bool isVerified;
  final bool isActive;

  // ── SELLER PROFILE ──
  final SellerProfile? sellerProfile;

  // ── PREFERENCES ──
  final UserPreferences preferences;

  // ── STATS ──
  final UserStats stats;

  // ── PRIVATE ──
  final String? bio;
  final List<String> socialLinks;
  final List<String> categories;

  // ============================================================
  // 🏗️ CONSTRUCTORS
  // ============================================================

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL = '',
    this.phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
    this.updatedAt,
    this.isSeller = false,
    this.isAdmin = false,
    this.isVerified = false,
    this.isActive = true,
    this.sellerProfile,
    UserPreferences? preferences,
    UserStats? stats,
    this.bio,
    this.socialLinks = const [],
    this.categories = const [],
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now(),
       preferences = preferences ?? UserPreferences(),
       stats = stats ?? UserStats();

  // ── FROM FIREBASE USER ──
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL ?? '',
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLogin: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  // ── FROM FIRESTORE ──
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      phoneNumber: data['phoneNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isSeller: data['isSeller'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      sellerProfile: data['sellerProfile'] != null
          ? SellerProfile.fromMap(data['sellerProfile'])
          : null,
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
      bio: data['bio'],
      socialLinks: List<String>.from(data['socialLinks'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
    );
  }

  // ── EMPTY USER ──
  factory UserModel.empty() {
    return UserModel(id: '', email: '', displayName: '');
  }

  // ============================================================
  // 🔄 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isSeller': isSeller,
      'isAdmin': isAdmin,
      'isVerified': isVerified,
      'isActive': isActive,
      'sellerProfile': sellerProfile?.toMap(),
      'preferences': preferences.toMap(),
      'stats': stats.toMap(),
      'bio': bio,
      'socialLinks': socialLinks,
      'categories': categories,
    };
  }

  // ============================================================
  // 📋 COPY WITH
  // ============================================================

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? updatedAt,
    bool? isSeller,
    bool? isAdmin,
    bool? isVerified,
    bool? isActive,
    SellerProfile? sellerProfile,
    UserPreferences? preferences,
    UserStats? stats,
    String? bio,
    List<String>? socialLinks,
    List<String>? categories,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      updatedAt: updatedAt ?? this.updatedAt,
      isSeller: isSeller ?? this.isSeller,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      sellerProfile: sellerProfile ?? this.sellerProfile,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      categories: categories ?? this.categories,
    );
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool get isValid {
    return id.isNotEmpty && email.isNotEmpty && displayName.isNotEmpty;
  }

  bool get hasPhoto {
    return photoURL.isNotEmpty;
  }

  bool get isComplete {
    return isValid && hasPhoto && phoneNumber != null;
  }

  bool get canSell {
    return isSeller && isVerified && isActive;
  }

  // ============================================================
  // 📊 GETTERS
  // ============================================================

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String get sellerSince {
    if (sellerProfile == null) return '';
    return '${sellerProfile!.joinedDate.year}-${sellerProfile!.joinedDate.month.toString().padLeft(2, '0')}';
  }

  int get totalListings {
    return sellerProfile?.totalListings ?? 0;
  }

  int get totalSales {
    return sellerProfile?.totalSales ?? 0;
  }

  double get sellerRating {
    return sellerProfile?.rating ?? 0.0;
  }

  int get sellerRatingCount {
    return sellerProfile?.ratingCount ?? 0;
  }

  // ============================================================
  // 🔍 HELPER METHODS
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSeller': isSeller,
      'isAdmin': isAdmin,
      'isVerified': isVerified,
      'isActive': isActive,
      'sellerProfile': sellerProfile?.toJson(),
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
      'bio': bio,
      'socialLinks': socialLinks,
      'categories': categories,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'] ?? '',
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isSeller: json['isSeller'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      sellerProfile: json['sellerProfile'] != null
          ? SellerProfile.fromJson(json['sellerProfile'])
          : null,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      bio: json['bio'],
      socialLinks: List<String>.from(json['socialLinks'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
    );
  }

  // ============================================================
  // 📝 STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 👤 SELLER PROFILE
// ============================================================

class SellerProfile {
  final String bio;
  final List<String> socialLinks;
  final int totalListings;
  final int totalSales;
  final double rating;
  final int ratingCount;
  final DateTime joinedDate;
  final DateTime? lastActive;
  final bool isVerified;
  final bool isFeatured;

  SellerProfile({
    this.bio = '',
    this.socialLinks = const [],
    this.totalListings = 0,
    this.totalSales = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    DateTime? joinedDate,
    this.lastActive,
    this.isVerified = false,
    this.isFeatured = false,
  }) : joinedDate = joinedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'socialLinks': socialLinks,
      'totalListings': totalListings,
      'totalSales': totalSales,
      'rating': rating,
      'ratingCount': ratingCount,
      'joinedDate': Timestamp.fromDate(joinedDate),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
    };
  }

  factory SellerProfile.fromMap(Map<String, dynamic> map) {
    return SellerProfile(
      bio: map['bio'] ?? '',
      socialLinks: List<String>.from(map['socialLinks'] ?? []),
      totalListings: map['totalListings'] ?? 0,
      totalSales: map['totalSales'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      joinedDate: (map['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate(),
      isVerified: map['isVerified'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'socialLinks': socialLinks,
      'totalListings': totalListings,
      'totalSales': totalSales,
      'rating': rating,
      'ratingCount': ratingCount,
      'joinedDate': joinedDate.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'isVerified': isVerified,
      'isFeatured': isFeatured,
    };
  }

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      bio: json['bio'] ?? '',
      socialLinks: List<String>.from(json['socialLinks'] ?? []),
      totalListings: json['totalListings'] ?? 0,
      totalSales: json['totalSales'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      joinedDate: DateTime.parse(json['joinedDate']),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      isVerified: json['isVerified'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  SellerProfile copyWith({
    String? bio,
    List<String>? socialLinks,
    int? totalListings,
    int? totalSales,
    double? rating,
    int? ratingCount,
    DateTime? joinedDate,
    DateTime? lastActive,
    bool? isVerified,
    bool? isFeatured,
  }) {
    return SellerProfile(
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      totalListings: totalListings ?? this.totalListings,
      totalSales: totalSales ?? this.totalSales,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

// ============================================================
// ⚙️ USER PREFERENCES
// ============================================================

class UserPreferences {
  final bool darkMode;
  final String language;
  final bool notifications;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  UserPreferences({
    this.darkMode = false,
    this.language = 'en',
    this.notifications = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'language': language,
      'notifications': notifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'en',
      notifications: map['notifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory UserPreferences.fromJson(Map<String, dynamic> json) => fromMap(json);

  UserPreferences copyWith({
    bool? darkMode,
    String? language,
    bool? notifications,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

// ============================================================
// 📊 USER STATS
// ============================================================

class UserStats {
  final int totalDownloads;
  final int totalLikes;
  final int totalReviews;
  final int totalShares;
  final int totalViews;
  final int totalProductsUploaded;
  final int totalProductsSold;
  final double averageRating;
  final int followers;
  final int following;

  UserStats({
    this.totalDownloads = 0,
    this.totalLikes = 0,
    this.totalReviews = 0,
    this.totalShares = 0,
    this.totalViews = 0,
    this.totalProductsUploaded = 0,
    this.totalProductsSold = 0,
    this.averageRating = 0.0,
    this.followers = 0,
    this.following = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalDownloads': totalDownloads,
      'totalLikes': totalLikes,
      'totalReviews': totalReviews,
      'totalShares': totalShares,
      'totalViews': totalViews,
      'totalProductsUploaded': totalProductsUploaded,
      'totalProductsSold': totalProductsSold,
      'averageRating': averageRating,
      'followers': followers,
      'following': following,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalDownloads: map['totalDownloads'] ?? 0,
      totalLikes: map['totalLikes'] ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
      totalShares: map['totalShares'] ?? 0,
      totalViews: map['totalViews'] ?? 0,
      totalProductsUploaded: map['totalProductsUploaded'] ?? 0,
      totalProductsSold: map['totalProductsSold'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory UserStats.fromJson(Map<String, dynamic> json) => fromMap(json);

  UserStats copyWith({
    int? totalDownloads,
    int? totalLikes,
    int? totalReviews,
    int? totalShares,
    int? totalViews,
    int? totalProductsUploaded,
    int? totalProductsSold,
    double? averageRating,
    int? followers,
    int? following,
  }) {
    return UserStats(
      totalDownloads: totalDownloads ?? this.totalDownloads,
      totalLikes: totalLikes ?? this.totalLikes,
      totalReviews: totalReviews ?? this.totalReviews,
      totalShares: totalShares ?? this.totalShares,
      totalViews: totalViews ?? this.totalViews,
      totalProductsUploaded:
          totalProductsUploaded ?? this.totalProductsUploaded,
      totalProductsSold: totalProductsSold ?? this.totalProductsSold,
      averageRating: averageRating ?? this.averageRating,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
