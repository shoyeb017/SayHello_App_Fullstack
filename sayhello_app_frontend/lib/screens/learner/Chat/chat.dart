import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/models.dart';
import '../BottomTabs/Connect/others_profile_page.dart';

// Models for chat data (keeping original for backward compatibility)
class ChatUser {
  final String id;
  final String name;
  final String avatarUrl;
  final String country;
  final String flag;
  final int age;
  final String gender;
  final bool isOnline;
  final DateTime lastSeen;
  final List<String> interests;
  final String nativeLanguage;
  final String learningLanguage;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.country,
    required this.flag,
    required this.age,
    required this.gender,
    required this.isOnline,
    required this.lastSeen,
    required this.interests,
    required this.nativeLanguage,
    required this.learningLanguage,
  });

  // Factory method to create ChatUser from Learner model
  factory ChatUser.fromLearner(Learner learner) {
    return ChatUser(
      id: learner.id,
      name: learner.name,
      avatarUrl: learner.profileImage ?? '',
      country: learner.country,
      flag: _getCountryFlag(learner.country),
      age: _calculateAge(learner.dateOfBirth),
      gender: learner.gender == 'male' ? 'M' : 'F',
      isOnline: true, // Could be enhanced with real online status
      lastSeen: DateTime.now(), // Could be enhanced with real last seen
      interests: learner.interests,
      nativeLanguage: learner.nativeLanguage,
      learningLanguage: learner.learningLanguage,
    );
  }
}

String _getCountryFlag(String country) {
  switch (country.toLowerCase()) {
    case 'usa':
      return '🇺🇸';
    case 'spain':
      return '🇪🇸';
    case 'japan':
      return '🇯🇵';
    case 'korea':
      return '🇰🇷';
    case 'bangladesh':
      return '🇧🇩';
    default:
      return '🌍';
  }
}

int _calculateAge(DateTime dateOfBirth) {
  final now = DateTime.now();
  int age = now.year - dateOfBirth.year;
  if (now.month < dateOfBirth.month ||
      (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
    age--;
  }
  return age;
}

class ChatDetailPage extends StatefulWidget {
  final ChatUser user;

  const ChatDetailPage({super.key, required this.user});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize chat immediately and set up real-time listening
    _loadOrCreateChat().then((_) {
      // Initialize message count and ensure we scroll to bottom after messages are loaded
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _currentMessageCount = chatProvider.messages.length;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Subscribe to real-time updates if we have a current chat
      if (chatProvider.currentChat != null) {
        print(
          'ChatDetailPage: Setting up real-time subscription for chat: ${chatProvider.currentChat!.id}',
        );
        chatProvider.subscribeToRealTimeUpdates(chatProvider.currentChat!.id);
      }
    });
  }

  @override
  void dispose() {
    // Unsubscribe from real-time updates
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.unsubscribeFromRealTimeUpdates();

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrCreateChat() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      print('ChatDetailPage: Starting chat initialization');
      print('ChatDetailPage: Current user: ${authProvider.currentUser?.id}');
      print('ChatDetailPage: Chat partner: ${widget.user.id}');

      if (authProvider.currentUser != null &&
          authProvider.currentUser is Learner) {
        final currentUser = authProvider.currentUser as Learner;

        print(
          'ChatDetailPage: Loading or creating chat between ${currentUser.id} and ${widget.user.id}',
        );

        // Load or create chat between current user and chat partner
        await chatProvider.loadOrCreateChat(currentUser.id, widget.user.id);

        print(
          'ChatDetailPage: Chat loaded successfully, current chat: ${chatProvider.currentChat?.id}',
        );

        // Mark messages as read when entering chat
        await chatProvider.markChatMessagesAsRead(currentUser.id);

        print('ChatDetailPage: Messages marked as read');
      } else {
        print(
          'ChatDetailPage: Error - No current user or user is not a Learner',
        );
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('ChatDetailPage: Error in _loadOrCreateChat: $e');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chat: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      // Use jumpTo for immediate scrolling without animation to reduce UI overhead
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToBottomSmooth() {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.online;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = const Color(0xFF7a54ff);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.user.avatarUrl.isNotEmpty
                      ? NetworkImage(widget.user.avatarUrl)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: widget.user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                if (widget.user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    widget.user.isOnline
                        ? AppLocalizations.of(context)!.online
                        : '${AppLocalizations.of(context)!.lastSeen} ${_formatLastSeen(widget.user.lastSeen)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer2<ChatProvider, AuthProvider>(
        builder: (context, chatProvider, authProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load chat',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chatProvider.error ?? 'Unknown error',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      print('ChatDetailPage: Retry button pressed');
                      await _loadOrCreateChat();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final messages = chatProvider.messages;
          final currentUserId = authProvider.currentUser?.id ?? '';

          // Sort messages by creation time (chronological order)
          final sortedMessages = List<ChatMessage>.from(messages)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Auto-scroll when new messages arrive via real-time (same pattern as instructor group chat)
          final currentMessageCount = sortedMessages.length;
          if (currentMessageCount > _currentMessageCount &&
              _currentMessageCount > 0) {
            // New messages arrived, scroll smoothly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && sortedMessages.isNotEmpty) {
                _scrollToBottomSmooth();
              }
            });
          } else if (currentMessageCount > 0 && _currentMessageCount == 0) {
            // Initial load, scroll instantly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && sortedMessages.isNotEmpty) {
                _scrollToBottom();
              }
            });
          }
          _currentMessageCount = currentMessageCount;

          return Column(
            children: [
              // Messages List with Profile Header
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedMessages.length + 1, // +1 for profile header
                  itemBuilder: (context, index) {
                    // Show profile header as first item
                    if (index == 0) {
                      return _buildProfileHeader(
                        context,
                        isDark,
                        primaryPurple,
                      );
                    }

                    // Show messages (adjust index by -1)
                    final message = sortedMessages[index - 1];
                    final isCurrentUser = message.senderId == currentUserId;

                    return _buildMessageItem(
                      context,
                      message,
                      isCurrentUser,
                      isDark,
                      primaryPurple,
                      currentUserId,
                    );
                  },
                ),
              ),

              // Message Input
              _buildMessageInput(
                context,
                isDark,
                primaryPurple,
                chatProvider,
                currentUserId,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
    Color primaryPurple,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Image + Name, Gender, Language
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 30,
                backgroundImage: widget.user.avatarUrl.isNotEmpty
                    ? NetworkImage(widget.user.avatarUrl)
                    : null,
                backgroundColor: Colors.grey[300],
                child: widget.user.avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),

              // Name and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Gender and age
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.user.gender.toLowerCase() == 'male'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.user.gender.toLowerCase() == 'male'
                              ? Colors.blue
                              : Colors.pink,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.user.gender.toLowerCase() == 'male'
                                ? Icons.male
                                : Icons.female,
                            size: 16,
                            color: widget.user.gender.toLowerCase() == 'male'
                                ? Colors.blue
                                : Colors.pink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.user.age}',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.user.gender.toLowerCase() == 'male'
                                  ? Colors.blue
                                  : Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile view button
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OthersProfilePage(
                              userId: widget.user.id,
                              name: widget.user.name,
                              avatar: widget.user.avatarUrl,
                              nativeLanguage: widget.user.nativeLanguage,
                              learningLanguage: widget.user.learningLanguage,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.viewProfile,
                        style: const TextStyle(
                          color: Color(0xFF7a54ff),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Learning language
          Text(
            AppLocalizations.of(
              context,
            )!.chatLearningLanguage(widget.user.learningLanguage),
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Native language with flag
          Row(
            children: [
              Text(widget.user.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.chatLanguageEnthusiast(
                    widget.user.country,
                    widget.user.flag,
                  ),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Interests
          if (widget.user.interests.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.interests,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.user.interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryPurple.withOpacity(0.3)),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(fontSize: 12, color: primaryPurple),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    ChatMessage message,
    bool isCurrentUser,
    bool isDark,
    Color primaryPurple,
    String currentUserId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.user.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.user.avatarUrl)
                  : null,
              backgroundColor: Colors.grey[300],
              child: widget.user.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(
                            0xFFF0EAFF,
                          ) // Light purple for current user
                        : (isDark ? Colors.grey.shade800 : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: !isCurrentUser
                        ? Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message content
                      if (message.type == 'image')
                        Row(
                          children: [
                            Icon(
                              Icons.image,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Image',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          message.contentText ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: isCurrentUser
                                ? Colors.black87
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),

                      // Timestamp and status
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMessageTimestamp(message.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.status == 'read'
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 14,
                              color: message.status == 'read'
                                  ? Colors.blue
                                  : Colors.grey[600],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    bool isDark,
    Color primaryPurple,
    ChatProvider chatProvider,
    String currentUserId,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeMessage,
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(chatProvider, currentUserId),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: primaryPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: chatProvider.isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: chatProvider.isSending
                    ? null
                    : () => _sendMessage(chatProvider, currentUserId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(
    ChatProvider chatProvider,
    String currentUserId,
  ) async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Clear the input field immediately
    _messageController.clear();

    // Send the message
    final success = await chatProvider.sendMessage(
      messageText,
      senderId: currentUserId,
    );

    if (success) {
      // Scroll to bottom to show the new message with smooth animation
      _scrollToBottomSmooth();
    } else {
      // If failed, put the text back
      _messageController.text = messageText;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatMessageTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
