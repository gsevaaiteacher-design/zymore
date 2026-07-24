// ============================================================
// 📁 FILE: ai_chat_screen.dart
// 📍 LOCATION: lib/screens/ai_chat_screen.dart
// 🎯 PURPOSE: AI Chat Assistant Screen
// 🔗 USED BY: Navigation Bar, Home Screen
// 📝 DESCRIPTION:
//    This screen provides AI chat assistant features:
//    - Chat interface with AI
//    - Message history
//    - Typing indicator
//    - Quick suggestion chips
//    - Copy messages
//    - Clear chat
//    - Dark mode support
//    - Error handling
//    - Loading states
//
//    Z-FIXER COMPLIANT:
//    - No direct module communication
//    - Complete error handling
//    - Event-driven state changes
//    - Telemetry ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// ============================================================
// 📁 IMPORT PROVIDERS, WIDGETS, UTILS
// ============================================================
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/custom_app_bar.dart';

// ============================================================
// 📊 CHAT MESSAGE MODEL
// ============================================================

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isTyping = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

// ============================================================
// 🎯 AI CHAT SCREEN
// ============================================================

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with SingleTickerProviderStateMixin {
  // ── CONTROLLERS ──
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── STATE ──
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ── SUGGESTIONS ──
  final List<String> _suggestions = [
    'Suggest a wallpaper',
    'Find art for my project',
    'What\'s trending?',
    'Help me find icons',
    'Show me popular assets',
    'How to upload?',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🎨 INIT ANIMATIONS
  // ============================================================

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  // ============================================================
  // 📝 ADD WELCOME MESSAGE
  // ============================================================

  void _addWelcomeMessage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userName.isNotEmpty
        ? authProvider.userName
        : 'there';

    _messages.add(
      ChatMessage(
        id: 'welcome',
        text:
            '👋 Hello $userName! I\'m your AI assistant.\n\nI can help you with:\n• Finding the perfect digital assets\n• Answering questions about products\n• Providing recommendations\n• And much more!',
        isUser: false,
      ),
    );
  }

  // ============================================================
  // 📤 SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage({String? message}) async {
    final text = message ?? _messageController.text.trim();
    if (text.isEmpty) return;

    // Clear input
    _messageController.clear();

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
    );
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _errorMessage = null;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Track analytics
    // AnalyticsService().logEvent('ai_chat_message', parameters: {'text': text});

    try {
      // TODO: Call AI API
      // For now, simulate AI response
      await _simulateAiResponse(text);
    } catch (e) {
      setState(() {
        _isTyping = false;
        _errorMessage = 'Failed to get response. Please try again.';
        // Add error message
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: '⚠️ Sorry, I encountered an error. Please try again later.',
            isUser: false,
          ),
        );
      });
    }

    setState(() {
      _isTyping = false;
    });
    _scrollToBottom();
  }

  // ============================================================
  // 🤖 SIMULATE AI RESPONSE (Placeholder)
  // ============================================================

  Future<void> _simulateAiResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulate AI response based on keywords
    String response;
    final lower = userMessage.toLowerCase();

    if (lower.contains('wallpaper') || lower.contains('wall')) {
      response =
          '🖼️ I recommend checking out our "Nature" and "Abstract" wallpaper collections. They have some amazing high-resolution options! Would you like to see trending wallpapers?';
    } else if (lower.contains('art')) {
      response =
          '🎨 We have a fantastic digital art collection! From modern abstract to classical styles. Check out the "Art" category for some incredible pieces.';
    } else if (lower.contains('icon')) {
      response =
          '🎯 Our icon packs are very popular! We have minimalist, 3D, and material design styles. Which style interests you?';
    } else if (lower.contains('upload') || lower.contains('sell')) {
      response =
          '📤 To upload your creations, you need to enable Seller Mode in your profile settings. Once enabled, you can start uploading your digital products!';
    } else if (lower.contains('trend') || lower.contains('popular')) {
      response =
          '🔥 Currently trending: "Minimalist Wallpapers", "3D Icon Pack", and "Digital Art Collection". These have been downloaded over 10,000 times this week!';
    } else if (lower.contains('help')) {
      response =
          '🤖 I\'m here to help! You can ask me about:\n• Finding specific products\n• Uploading your creations\n• Trending items\n• Category recommendations\nJust type your question!';
    } else {
      response =
          'That\'s a great question! I\'d recommend exploring our categories: Wallpaper, Icon, Art, and Asset. Each has unique and high-quality digital products. Let me know what interests you!';
    }

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          isUser: false,
        ),
      );
    });
  }

  // ============================================================
  // 🎨 BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Assistant',
        subtitle: 'Powered by AI',
        showBackButton: true,
        showProfileAvatar: false,
        showSearch: false,
        showCart: false,
        actions: [
          // ── CLEAR CHAT ──
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _messages.length > 1 ? _clearChat : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── CHAT MESSAGES ──
          Expanded(child: _buildChatMessages(isDark)),

          // ── SUGGESTIONS ──
          if (_messages.length <= 2) _buildSuggestions(isDark),

          // ── INPUT BAR ──
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  // ============================================================
  // 💬 BUILD CHAT MESSAGES
  // ============================================================

  Widget _buildChatMessages(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _messages.length && _isTyping) {
              return _buildTypingIndicator(isDark);
            }
            final message = _messages[index];
            return _buildMessageBubble(message, isDark);
          },
        ),
      ),
    );
  }

  // ============================================================
  // 💬 BUILD MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.isUser;
    final alignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // ── AVATAR (AI) ──
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (!isUser) const SizedBox(width: 8),

          // ── BUBBLE ──
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: (isUser
                          ? Colors.white70
                          : (isDark ? Colors.white38 : Colors.grey[500])),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── AVATAR (User) ──
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ⌨️ BUILD TYPING INDICATOR
  // ============================================================

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: const Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // 💡 BUILD SUGGESTIONS
  // ============================================================

  Widget _buildSuggestions(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Quick Suggestions',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return ActionChip(
                label: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                onPressed: () => _sendMessage(message: suggestion),
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📝 BUILD INPUT BAR
  // ============================================================

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── TEXT INPUT ──
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400],
                    fontFamily: 'Inter',
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── SEND BUTTON ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🗑️ CLEAR CHAT
  // ============================================================

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('This will clear all chat messages. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📜 SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
