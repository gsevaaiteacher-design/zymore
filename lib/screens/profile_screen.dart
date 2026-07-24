// ============================================================
// 📁 FILE: profile_screen.dart
// 📍 LOCATION: lib/screens/profile_screen.dart
// 🎯 PURPOSE: User Profile Screen
// 🔗 USED BY: Bottom Navigation, App Bar
// 📝 DESCRIPTION:
//    This screen displays user profile with:
//    - User avatar and name
//    - Email and stats
//    - Seller mode toggle
//    - My listings
//    - My downloads
//    - Liked products
//    - Settings
//    - Sign out
//    - Edit profile
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================
// 📁 IMPORT MODELS, PROVIDERS, WIDGETS, UTILS
// ============================================================
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/custom_app_bar.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

// ============================================================
// 🎯 PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // 📤 LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Load user products
      await productProvider.fetchUserProducts();

      // Load liked products
      await productProvider.fetchLikedProducts();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Profile Load Error: $e');
    }
  }

  // ============================================================
  // 🔄 TOGGLE SELLER MODE
  // ============================================================

  Future<void> _toggleSellerMode() async {
    // TODO: Implement seller mode toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seller mode toggle coming soon!')),
    );
  }

  // ============================================================
  // 🚪 SIGN OUT
  // ============================================================

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });

              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final result = await authProvider.signOut();

              setState(() {
                _isLoading = false;
              });

              if (result) {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        showBackButton: true,
        showProfileAvatar: false,
        showSearch: false,
        showCart: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── PROFILE HEADER ──
                  _buildProfileHeader(authProvider, isDark),
                  const SizedBox(height: 20),

                  // ── STATS CARD ──
                  _buildStatsCard(
                    authProvider,
                    productProvider,
                    cartProvider,
                    isDark,
                  ),
                  const SizedBox(height: 20),

                  // ── SELLER MODE ──
                  _buildSellerModeCard(authProvider, isDark),
                  const SizedBox(height: 20),

                  // ── MENU ITEMS ──
                  _buildMenuItems(authProvider, isDark),
                  const SizedBox(height: 20),

                  // ── POWERED BY ──
                  _buildPoweredBy(isDark),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 👤 BUILD PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(AuthProvider authProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── AVATAR ──
          CircleAvatar(
            radius: 40,
            backgroundImage: authProvider.userPhoto.isNotEmpty
                ? NetworkImage(authProvider.userPhoto)
                : null,
            backgroundColor: AppColors.primary,
            child: authProvider.userPhoto.isEmpty
                ? Text(
                    authProvider.userName.isNotEmpty
                        ? authProvider.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // ── NAME & EMAIL ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.userName.isNotEmpty
                      ? authProvider.userName
                      : 'Guest User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authProvider.userEmail.isNotEmpty
                      ? authProvider.userEmail
                      : 'No email',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: authProvider.isSeller
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authProvider.isSeller ? '👨‍💼 Seller' : '👤 User',
                    style: TextStyle(
                      fontSize: 12,
                      color: authProvider.isSeller
                          ? Colors.green[600]
                          : Colors.orange[600],
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── EDIT BUTTON ──
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            onPressed: () {
              // TODO: Edit profile
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 BUILD STATS CARD
  // ============================================================

  Widget _buildStatsCard(
    AuthProvider authProvider,
    ProductProvider productProvider,
    CartProvider cartProvider,
    bool isDark,
  ) {
    final stats = [
      {
        'label': 'Listings',
        'value': productProvider.userProducts.length.toString(),
        'icon': Icons.inventory_2_outlined,
      },
      {'label': 'Downloads', 'value': '0', 'icon': Icons.download_outlined},
      {
        'label': 'Likes',
        'value': productProvider.likedProducts.length.toString(),
        'icon': Icons.favorite_outline,
      },
      {
        'label': 'Cart',
        'value': cartProvider.cartCount.toString(),
        'icon': Icons.shopping_cart_outlined,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return Column(
            children: [
              Icon(
                stat['icon'] as IconData,
                color: isDark ? Colors.white54 : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                stat['value'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                stat['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey[500],
                  fontFamily: 'Inter',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // 🔄 BUILD SELLER MODE CARD
  // ============================================================

  Widget _buildSellerModeCard(AuthProvider authProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.storefront, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  authProvider.isSeller
                      ? 'You are currently in Seller Mode'
                      : 'Switch to Seller Mode to upload products',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: authProvider.isSeller,
            onChanged: (_) => _toggleSellerMode(),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📋 BUILD MENU ITEMS
  // ============================================================

  Widget _buildMenuItems(AuthProvider authProvider, bool isDark) {
    final menuItems = [
      {
        'icon': Icons.history,
        'title': 'Download History',
        'subtitle': 'View your download history',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        },
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Liked Products',
        'subtitle': 'Products you have liked',
        'onTap': () {
          // TODO: Show liked products
        },
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'My Listings',
        'subtitle': 'Products you have uploaded',
        'onTap': () {
          // TODO: Show my listings
        },
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'subtitle': 'App settings and preferences',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'FAQs and support',
        'onTap': () {
          // TODO: Show help
        },
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy Policy',
        'subtitle': 'Read our privacy policy',
        'onTap': () {
          // TODO: Show privacy policy
        },
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            onTap: item['onTap'] as VoidCallback,
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // ⚡ BUILD POWERED BY
  // ============================================================

  Widget _buildPoweredBy(bool isDark) {
    return Column(
      children: [
        Divider(
          color: isDark ? Colors.white12 : Colors.grey[300],
          thickness: 1,
          indent: 60,
          endIndent: 60,
        ),
        const SizedBox(height: 12),
        Text(
          '⚡ Powered By',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.grey[500],
            fontFamily: 'Inter',
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppConstants.poweredBy,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Poppins',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${AppConstants.appVersion}',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white24 : Colors.grey[400],
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 20),
        // ── SIGN OUT BUTTON ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
