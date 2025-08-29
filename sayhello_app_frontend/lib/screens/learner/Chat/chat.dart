import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/models.dart';
import '../../../services/azure_translator_service.dart';
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
  ChatProvider? _chatProvider;
  bool _isSubscribedToRealTime = false; // Track subscription status
  Set<String> _renderedMessageIds = {}; // Track rendered message IDs
  bool _isSendingMessage = false; // Track sending state to prevent double-send

  // Track which messages have been translated or corrected
  Set<String> _translatedMessages = {};
  Set<String> _correctedMessages = {};
  Map<String, String> _messageTranslations = {};
  Map<String, String> _messageCorrections = {};

  @override
  void initState() {
    super.initState();
    // Initialize chat immediately and set up real-time listening
    _loadOrCreateChat().then((_) {
      // Initialize message count and ensure we scroll to bottom after messages are loaded
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _currentMessageCount = chatProvider.messages.length;

      // Ensure we start at the bottom when opening chat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _scrollController.hasClients &&
            chatProvider.messages.isNotEmpty) {
          // Instantly jump to bottom without animation to prevent "flash" effect
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      // Subscribe to real-time updates if we have a current chat
      if (chatProvider.currentChat != null && !_isSubscribedToRealTime) {
        print(
          'ChatDetailPage: Setting up real-time subscription for chat: ${chatProvider.currentChat!.id}',
        );
        chatProvider.subscribeToRealTimeUpdates(chatProvider.currentChat!.id);
        _isSubscribedToRealTime = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store reference to ChatProvider for use in dispose()
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // Unsubscribe from real-time updates using stored reference
    if (_isSubscribedToRealTime) {
      _chatProvider?.unsubscribeFromRealTimeUpdates();
      _isSubscribedToRealTime = false;
    }

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

  void _scrollToBottomSmooth() {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), // Faster animation
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
          onPressed: () {
            // Return with success flag to trigger immediate refresh in home page
            Navigator.pop(context, true);
          },
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
          // Only show loading on initial load when no chat exists yet
          if (chatProvider.isLoading && chatProvider.currentChat == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.hasError && chatProvider.currentChat == null) {
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

          // Deduplicate messages by ID and sort by creation time (chronological order)
          final Map<String, ChatMessage> messageMap = {};
          for (final message in messages) {
            messageMap[message.id] = message;
          }

          final sortedMessages = messageMap.values.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Check for truly new messages (not just duplicates)
          final newMessageIds = sortedMessages.map((m) => m.id).toSet();
          final hasNewUniqueMessages = !newMessageIds.every(
            (id) => _renderedMessageIds.contains(id),
          );

          // Update rendered message IDs for duplicate detection
          _renderedMessageIds = newMessageIds;

          // Debug: Log if duplicates were found
          if (messages.length != sortedMessages.length) {
            print(
              'ChatDetailPage: Removed ${messages.length - sortedMessages.length} duplicate messages',
            );
          }

          // Handle scrolling only when messages actually change (by unique IDs, not just count)
          final currentMessageCount = sortedMessages.length;
          final shouldScroll =
              hasNewUniqueMessages ||
              (_currentMessageCount != currentMessageCount);

          if (shouldScroll) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                if (_currentMessageCount == 0 && currentMessageCount > 0) {
                  // Initial load - scroll to bottom instantly without animation
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                } else if (currentMessageCount > _currentMessageCount &&
                    _currentMessageCount > 0) {
                  // New message arrived - smooth scroll
                  _scrollToBottomSmooth();
                }
              }
            });
            _currentMessageCount = currentMessageCount;
          }

          return Column(
            children: [
              // Messages List - start from bottom to prevent jumping
              Expanded(
                child: sortedMessages.isEmpty
                    ? _buildEmptyStateWithProfile(
                        context,
                        isDark,
                        primaryPurple,
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            sortedMessages.length + 1, // +1 for profile header
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
                          final isCurrentUser =
                              message.senderId == currentUserId;

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

  Widget _buildEmptyStateWithProfile(
    BuildContext context,
    bool isDark,
    Color primaryPurple,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(context, isDark, primaryPurple),
          const SizedBox(height: 40),
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start your conversation!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Say hello to ${widget.user.name}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
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
                // Message Bubble with Stack for action icons
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                          // Message content with correction display
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
                          else if (message.hasCorrection ||
                              _correctedMessages.contains(message.id))
                            // Show corrected message format (visible to both sender and receiver)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        message.contentText ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Colors.red,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        message.correction ??
                                            _messageCorrections[message.id] ??
                                            AppLocalizations.of(
                                              context,
                                            )!.chatCorrectedText,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  ],
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

                          // Translation display - show if message has been translated
                          if (!isCurrentUser &&
                              _translatedMessages.contains(message.id)) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.translate,
                                    size: 16,
                                    color: primaryPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _messageTranslations[message.id] ??
                                          AppLocalizations.of(
                                            context,
                                          )!.chatTranslationHere,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: primaryPurple,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

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

                    // Action icons positioned on the border of message bubble
                    if (!isCurrentUser && message.type != 'image')
                      Positioned(
                        bottom: -8,
                        right: 12,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Translate icon
                            GestureDetector(
                              onTap: () {
                                print('Translate icon tapped!');
                                _autoTranslateMessage(message, primaryPurple);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryPurple.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.translate,
                                  size: 12,
                                  color: primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Correct icon
                            GestureDetector(
                              onTap: () {
                                print('Correct icon tapped!');
                                _showCorrectDialog(
                                  context,
                                  message,
                                  primaryPurple,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryPurple.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
                icon: _isSendingMessage
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
                onPressed: _isSendingMessage
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
    if (messageText.isEmpty || _isSendingMessage) return;

    // Set our own sending flag to prevent double-tap sends
    setState(() {
      _isSendingMessage = true;
    });

    // Clear the input field immediately for instant feedback
    _messageController.clear();

    // Instantly scroll to bottom to show typing area cleared
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }

    try {
      // Send the message asynchronously without waiting for provider state
      chatProvider
          .sendMessage(messageText, senderId: currentUserId)
          .then((success) {
            if (!success && mounted) {
              // If failed, put the text back and show error
              _messageController.text = messageText;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to send message. Please try again.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          })
          .catchError((e) {
            // Error handling - restore message text
            if (mounted) {
              _messageController.text = messageText;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error sending message. Check your connection.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });

      // Reset sending flag quickly for immediate UI feedback
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });

        // Scroll to bottom smoothly to show the new message
        _scrollToBottomSmooth();
      }
    } catch (e) {
      // Reset sending flag immediately on error
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
        _messageController.text = messageText;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message. Check your connection.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
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

  // Auto-translate message using Azure Translator Service
  void _autoTranslateMessage(ChatMessage message, Color primaryPurple) async {
    print('_autoTranslateMessage called for: ${message.contentText}');

    try {
      // Get current user's learning language for translation
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser as Learner?;

      if (currentUser == null) {
        print('No current user found for translation');
        return;
      }

      // Show loading feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Translating message...'),
            ],
          ),
          backgroundColor: primaryPurple,
          duration: Duration(seconds: 3),
        ),
      );

      // Convert language names to proper capitalized format for Azure Translator
      final sourceLanguage = _getProperLanguageName(widget.user.nativeLanguage);
      final targetLanguage = _getProperLanguageName(currentUser.nativeLanguage);

      print('Translating from $sourceLanguage to $targetLanguage');

      // Translate from the partner's native language to current user's native language
      final translation = await AzureTranslatorService.translateText(
        text: message.contentText ?? '',
        sourceLanguage: sourceLanguage, // Partner's native language
        targetLanguage:
            targetLanguage, // User's native language for understanding
      );

      print('Translation result: $translation');

      if (mounted && translation.isNotEmpty) {
        setState(() {
          _translatedMessages.add(message.id);
          _messageTranslations[message.id] = translation;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Message translated to ${currentUser.nativeLanguage}!',
            ),
            backgroundColor: primaryPurple,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Translation error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Convert language names to proper format for Azure Translator Service
  String _getProperLanguageName(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english':
        return 'English';
      case 'spanish':
        return 'Spanish';
      case 'french':
        return 'French';
      case 'german':
        return 'German';
      case 'italian':
        return 'Italian';
      case 'portuguese':
        return 'Portuguese';
      case 'russian':
        return 'Russian';
      case 'japanese':
        return 'Japanese';
      case 'korean':
        return 'Korean';
      case 'chinese':
        return 'Chinese';
      case 'arabic':
        return 'Arabic';
      case 'hindi':
        return 'Hindi';
      case 'bengali':
        return 'Bengali';
      case 'urdu':
        return 'Urdu';
      case 'turkish':
        return 'Turkish';
      case 'dutch':
        return 'Dutch';
      case 'swedish':
        return 'Swedish';
      case 'norwegian':
        return 'Norwegian';
      case 'danish':
        return 'Danish';
      case 'finnish':
        return 'Finnish';
      case 'polish':
        return 'Polish';
      case 'czech':
        return 'Czech';
      case 'hungarian':
        return 'Hungarian';
      case 'romanian':
        return 'Romanian';
      case 'bulgarian':
        return 'Bulgarian';
      case 'greek':
        return 'Greek';
      case 'hebrew':
        return 'Hebrew';
      case 'thai':
        return 'Thai';
      case 'vietnamese':
        return 'Vietnamese';
      case 'indonesian':
        return 'Indonesian';
      case 'malay':
        return 'Malay';
      case 'filipino':
        return 'Filipino';
      default:
        // Default to English if language not found, but preserve original case
        return languageName.isNotEmpty
            ? languageName[0].toUpperCase() +
                  languageName.substring(1).toLowerCase()
            : 'English';
    }
  }

  // Show correction dialog
  void _showCorrectDialog(
    BuildContext context,
    ChatMessage message,
    Color primaryPurple,
  ) {
    final TextEditingController correctionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chatDialogCorrectMessage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.chatDialogOriginal,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message.contentText ?? ''),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.chatDialogCorrection,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: correctionController,
              decoration: InputDecoration(
                hintText: 'Enter your correction',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.chatDialogCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (correctionController.text.trim().isNotEmpty) {
                try {
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );

                  // Save correction to database using the repository
                  await chatProvider.updateMessageCorrection(
                    message.id,
                    correctionController.text.trim(),
                  );

                  // Also save locally for immediate UI update
                  setState(() {
                    _correctedMessages.add(message.id);
                    _messageCorrections[message.id] = correctionController.text
                        .trim();
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.chatDialogCorrectionSaved,
                      ),
                      backgroundColor: primaryPurple,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error saving correction: $e');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving correction: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
            child: Text(
              AppLocalizations.of(context)!.chatDialogSave,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
