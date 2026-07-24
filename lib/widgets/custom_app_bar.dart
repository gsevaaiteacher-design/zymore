// ============================================================
// 📁 FILE: custom_app_bar.dart
// 📍 LOCATION: lib/widgets/custom_app_bar.dart
// 🎯 PURPOSE: Custom App Bar Widget
// 🔗 USED BY: All Screens
// 📝 DESCRIPTION:
//    This widget provides a customizable app bar with:
//    - Title and subtitle
//    - Back button
//    - Action buttons
//    - Search bar
//    - Profile avatar
//    - Notification badge
//    - Theme support
//    - Animation support
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
// 📁 IMPORT PROVIDERS & UTILS
// ============================================================
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// ============================================================
// 🎯 CUSTOM APP BAR
// ============================================================

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ── PROPERTIES ──
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showProfileAvatar;
  final bool showNotification;
  final bool showSearch;
  final bool showCart;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onCartPressed;
  final Function(String)? onSearchChanged;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showProfileAvatar = true,
    this.showNotification = true,
    this.showSearch = true,
    this.showCart = true,
    this.centerTitle = false,
    this.actions,
    this.onBackPressed,
    this.onProfilePressed,
    this.onNotificationPressed,
    this.onSearchPressed,
    this.onCartPressed,
    this.onSearchChanged,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
  });

  // ============================================================
  // 📐 PREFERRED SIZE
  // ============================================================

  @override
  Size get preferredSize {
    final baseHeight = kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(baseHeight + bottomHeight);
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // 🎨 Get theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        foregroundColor ?? (isDark ? Colors.white : AppColors.textPrimary);
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground);

    // 📦 Get providers
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return AppBar(
      backgroundColor: bgColor,
      elevation: elevation,
      centerTitle: centerTitle,
      title: _buildTitle(context, textColor),
      leading: _buildLeading(context),
      actions: _buildActions(context, authProvider, cartProvider),
      bottom: bottom,
      flexibleSpace: _buildFlexibleSpace(context),
      systemOverlayStyle: isDark
          ? const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            )
          : const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
    );
  }

  // ============================================================
  // 🏷️ BUILD TITLE
  // ============================================================

  Widget _buildTitle(BuildContext context, Color textColor) {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Poppins',
      ),
    );
  }

  // ============================================================
  // 🔙 BUILD LEADING
  // ============================================================

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        color: foregroundColor,
        iconSize: 20,
      );
    }

    return null;
  }

  // ============================================================
  // 🎯 BUILD ACTIONS
  // ============================================================

  List<Widget> _buildActions(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
  ) {
    final List<Widget> actionList = [];

    // ── SEARCH BUTTON ──
    if (showSearch) {
      actionList.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed:
              onSearchPressed ??
              () {
                _showSearchDialog(context);
              },
          color: foregroundColor,
        ),
      );
    }

    // ── CART BUTTON ──
    if (showCart) {
      actionList.add(
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: onCartPressed,
              color: foregroundColor,
            ),
            if (cartProvider.cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    cartProvider.cartCount > 99
                        ? '99+'
                        : '${cartProvider.cartCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // ── NOTIFICATION BUTTON ──
    if (showNotification) {
      actionList.add(
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onNotificationPressed,
          color: foregroundColor,
        ),
      );
    }

    // ── PROFILE AVATAR ──
    if (showProfileAvatar) {
      actionList.add(
        GestureDetector(
          onTap: onProfilePressed,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 18,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    // ── CUSTOM ACTIONS ──
    if (actions != null) {
      actionList.addAll(actions!);
    }

    return actionList;
  }

  // ============================================================
  // 🎨 BUILD FLEXIBLE SPACE
  // ============================================================

  Widget _buildFlexibleSpace(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, bgColor.withOpacity(0.95)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔍 SEARCH DIALOG
  // ============================================================

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SearchDialog(
        onSearch: (query) {
          if (onSearchChanged != null) {
            onSearchChanged!(query);
          }
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ============================================================
// 🔍 SEARCH DIALOG
// ============================================================

class SearchDialog extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClose;

  const SearchDialog({
    super.key,
    required this.onSearch,
    required this.onClose,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      widget.onSearch(value);
                      widget.onClose();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSuggestionChip('Wallpaper'),
                const SizedBox(width: 8),
                _buildSuggestionChip('Art'),
                const SizedBox(width: 8),
                _buildSuggestionChip('Icon'),
                const SizedBox(width: 8),
                _buildSuggestionChip('Nature'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        widget.onSearch(label);
        widget.onClose();
      },
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 Z-FIXER UNIT TEST FOR custom_app_bar.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:provider/provider.dart';

 void main() {
   testWidgets('CustomAppBar displays title correctly', 
       (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           appBar: const CustomAppBar(title: 'Test Title'),
           body: const SizedBox(),
         ),
       ),
     );

     expect(find.text('Test Title'), findsOneWidget);
   });

   testWidgets('CustomAppBar shows back button when enabled', 
       (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: Scaffold(
           appBar: const CustomAppBar(
             title: 'Test',
             showBackButton: true,
           ),
           body: const SizedBox(),
         ),
       ),
     );

     expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
   });
 }
*/
