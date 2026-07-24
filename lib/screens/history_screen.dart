// ============================================================
// 📁 FILE: history_screen.dart
// 📍 LOCATION: lib/screens/history_screen.dart
// 🎯 PURPOSE: Download History Screen
// 🔗 USED BY: Bottom Navigation, Profile Screen
// 📝 DESCRIPTION:
//    This screen displays user's download history:
//    - List of downloaded products
//    - Download status (completed, failed, pending)
//    - Download progress
//    - File size and date
//    - Open downloaded file
//    - Delete from history
//    - Filter by status
//    - Search in history
//    - Clear history
//    - Empty state
//    - Error handling
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
import '../models/download_history.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/custom_app_bar.dart';

// ============================================================
// 🎯 HISTORY SCREEN
// ============================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── STATE ──
  List<DownloadHistory> _history = [];
  List<DownloadHistory> _filteredHistory = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all';
  String _searchQuery = '';

  // ── FILTER OPTIONS ──
  final List<String> _filterOptions = [
    'all',
    'completed',
    'downloading',
    'pending',
    'failed',
    'paused',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ============================================================
  // 📤 LOAD HISTORY
  // ============================================================

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Load download history from database
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // final databaseService = DatabaseService();
      // _history = await databaseService.getUserDownloadHistory(authProvider.userId);

      // Mock data for testing
      _history = _getMockHistory();

      _applyFilters();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load history';
      });
      print('❌ History Load Error: $e');
    }
  }

  // ============================================================
  // 🔍 APPLY FILTERS
  // ============================================================

  void _applyFilters() {
    _filteredHistory = _history.where((item) {
      // Filter by status
      if (_filterStatus != 'all' &&
          item.status.toStringValue() != _filterStatus) {
        return false;
      }

      // Filter by search
      if (_searchQuery.isNotEmpty) {
        return item.productTitle.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }

      return true;
    }).toList();
  }

  // ============================================================
  // 🗑️ DELETE HISTORY ITEM
  // ============================================================

  Future<void> _deleteHistoryItem(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: const Text(
          'Are you sure you want to delete this history item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _history.removeWhere((item) => item.id == id);
                _applyFilters();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History item deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🗑️ CLEAR ALL HISTORY
  // ============================================================

  Future<void> _clearAllHistory() async {
    if (_history.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all download history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _history.clear();
                _applyFilters();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📂 OPEN DOWNLOADED FILE
  // ============================================================

  Future<void> _openFile(DownloadHistory item) async {
    // TODO: Implement file opening
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open file functionality coming soon!')),
    );
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Download History',
        showBackButton: true,
        showProfileAvatar: false,
        showSearch: false,
        showCart: false,
        actions: [
          // ── CLEAR HISTORY ──
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _history.isEmpty
          ? _buildEmptyState(isDark)
          : _buildContent(isDark),
    );
  }

  // ============================================================
  // 📦 BUILD CONTENT
  // ============================================================

  Widget _buildContent(bool isDark) {
    return Column(
      children: [
        // ── FILTER BAR ──
        _buildFilterBar(isDark),
        const SizedBox(height: 8),

        // ── SEARCH BAR ──
        _buildSearchBar(isDark),
        const SizedBox(height: 8),

        // ── HISTORY LIST ──
        Expanded(
          child: _filteredHistory.isEmpty
              ? _buildNoResultsState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = _filteredHistory[index];
                    return _buildHistoryItem(item, isDark);
                  },
                ),
        ),
      ],
    );
  }

  // ============================================================
  // 🔍 BUILD FILTER BAR
  // ============================================================

  Widget _buildFilterBar(bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _filterStatus == option;
          final label = option.toUpperCase();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterStatus = option;
                  _applyFilters();
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 🔍 BUILD SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search history...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  // ============================================================
  // 📋 BUILD HISTORY ITEM
  // ============================================================

  Widget _buildHistoryItem(DownloadHistory item, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.cardBackgroundDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.productThumbnail,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        title: Text(
          item.productTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  item.fileSizeDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildStatusChip(item),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
          onSelected: (value) {
            switch (value) {
              case 'open':
                _openFile(item);
                break;
              case 'delete':
                _deleteHistoryItem(item.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.folder_open, size: 20),
                  SizedBox(width: 8),
                  Text('Open File'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏷️ BUILD STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(DownloadHistory item) {
    Color color;
    IconData icon;

    switch (item.status) {
      case DownloadStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DownloadStatus.downloading:
        color = Colors.blue;
        icon = Icons.downloading;
        break;
      case DownloadStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case DownloadStatus.failed:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        icon = Icons.pause_circle_outline;
        break;
      case DownloadStatus.cancelled:
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            item.statusDisplay,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📦 BUILD EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📭', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No Download History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your downloaded products will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📦 BUILD NO RESULTS STATE
  // ============================================================

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.grey[600],
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ❌ BUILD ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📊 MOCK DATA
  // ============================================================

  List<DownloadHistory> _getMockHistory() {
    return [
      DownloadHistory(
        id: '1',
        userId: 'user_1',
        productId: 'prod_1',
        productTitle: 'Beautiful Sunset Wallpaper',
        productThumbnail:
            'https://via.placeholder.com/100/FF6B35/FFFFFF?text=Sunset',
        downloadUrl: 'https://example.com/file1.zip',
        fileType: 'zip',
        fileSize: 15 * 1024 * 1024,
        fileName: 'sunset_wallpaper.zip',
        status: DownloadStatus.completed,
        downloadedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 55),
        ),
        localPath: '/downloads/sunset_wallpaper.zip',
      ),
      DownloadHistory(
        id: '2',
        userId: 'user_1',
        productId: 'prod_2',
        productTitle: 'Premium Icon Pack',
        productThumbnail:
            'https://via.placeholder.com/100/00D4FF/FFFFFF?text=Icons',
        downloadUrl: 'https://example.com/file2.zip',
        fileType: 'zip',
        fileSize: 8 * 1024 * 1024,
        fileName: 'premium_icons.zip',
        status: DownloadStatus.downloading,
        progress: 65,
        downloadedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        localPath: null,
      ),
      DownloadHistory(
        id: '3',
        userId: 'user_1',
        productId: 'prod_3',
        productTitle: 'Digital Art Collection',
        productThumbnail:
            'https://via.placeholder.com/100/9B59B6/FFFFFF?text=Art',
        downloadUrl: 'https://example.com/file3.zip',
        fileType: 'zip',
        fileSize: 25 * 1024 * 1024,
        fileName: 'digital_art.zip',
        status: DownloadStatus.failed,
        errorMessage: 'Network error',
        downloadedAt: DateTime.now().subtract(const Duration(hours: 5)),
        localPath: null,
      ),
      DownloadHistory(
        id: '4',
        userId: 'user_1',
        productId: 'prod_4',
        productTitle: '3D Asset Pack',
        productThumbnail:
            'https://via.placeholder.com/100/2ECC71/FFFFFF?text=3D',
        downloadUrl: 'https://example.com/file4.zip',
        fileType: 'zip',
        fileSize: 45 * 1024 * 1024,
        fileName: '3d_assets.zip',
        status: DownloadStatus.completed,
        downloadedAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        localPath: '/downloads/3d_assets.zip',
      ),
    ];
  }
}
