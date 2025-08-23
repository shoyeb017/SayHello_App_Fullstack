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

  static String _getCountryFlag(String country) {
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

  static int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

enum MessageType { text, sticker, voice, image }

// Individual Chat Detail Page
class ChatDetailPage extends StatefulWidget {
  final ChatUser user;

  const ChatDetailPage({super.key, required this.user});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Track which messages have been translated or corrected
  Set<String> _translatedMessages = {};
  Set<String> _correctedMessages = {};
  Map<String, String> _messageTranslations = {};
  Map<String, String> _messageCorrections = {};

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() async {
    await _loadOrCreateChat();
    _scrollToBottom();
    _startMessagePolling();
  }

  void _startMessagePolling() {
    // Start polling for new messages every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (chatProvider.currentChat != null &&
          authProvider.currentUser != null) {
        chatProvider.loadUserChats((authProvider.currentUser as Learner).id);
      }
    });
  }

  Future<void> _loadOrCreateChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser != null &&
        authProvider.currentUser is Learner) {
      final currentUser = authProvider.currentUser as Learner;
      await chatProvider.loadOrCreateChat(currentUser.id, widget.user.id);

      // Mark messages as read when entering chat
      await chatProvider.markChatMessagesAsRead(currentUser.id);
    }
  }

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
        actions: [
          // Actions can be added here if needed
        ],
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
                  TextButton(
                    onPressed: () => _loadOrCreateChat(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final messages = chatProvider.messages;
          final currentUserId = authProvider.currentUser?.id ?? '';

          return Column(
            children: [
              // Messages List with Profile Header
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + 1, // +1 for profile header
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
                    final message = messages[index - 1];
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
                backgroundImage: NetworkImage(widget.user.avatarUrl),
              ),
              const SizedBox(width: 16),
              // Name, Gender, Language info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name, Gender Icon, Age, and Arrow
                    Row(
                      children: [
                        Text(
                          widget.user.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Gender icon and age in colored rounded box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: widget.user.gender.toLowerCase() == 'male'
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
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
                                color:
                                    widget.user.gender.toLowerCase() == 'male'
                                    ? Colors.blue
                                    : Colors.pink,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.user.age}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      widget.user.gender.toLowerCase() == 'male'
                                      ? Colors.blue
                                      : Colors.pink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
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
                                  learningLanguage:
                                      widget.user.learningLanguage,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Learning Language
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.chatLearningLanguage(widget.user.learningLanguage),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Second row: Bio
          Text(
            AppLocalizations.of(
              context,
            )!.chatLanguageEnthusiast(widget.user.country, widget.user.flag),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Third row: Interest bubbles (gray background with black text)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.user.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
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
      margin: const EdgeInsets.only(bottom: 16, top: 16),
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
                // Message Bubble with action icons
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
                          // Main message text
                          if (message.type == 'image')
                            Text(
                              '📎 Image',
                              style: const TextStyle(fontSize: 16),
                            )
                          else if (_correctedMessages.contains(message.id))
                            // Show corrected message with strikethrough
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
                                    ? Colors.black
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),

                          // Translation - show if message has been translated
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
                        ],
                      ),
                    ),

                    // Action icons positioned on the border of message bubble
                    if (!isCurrentUser && message.type == 'text')
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
                                  color: Colors.white,
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
                                  color: Colors.white,
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

                // Timestamp & Read Status
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatMessageTimestamp(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (isCurrentUser && message.status == 'read')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      AppLocalizations.of(context)!.chatRead,
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=99',
              ),
            ),
          ],
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
                  onSubmitted: (_) {
                    final chatProvider = Provider.of<ChatProvider>(
                      context,
                      listen: false,
                    );
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final currentUserId = authProvider.currentUser?.id ?? '';
                    _sendMessage(chatProvider, currentUserId);
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: chatProvider.isSending ? Colors.grey : primaryPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: chatProvider.isSending
                    ? const SizedBox(
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
                    : () {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final currentUserId =
                            authProvider.currentUser?.id ?? '';
                        _sendMessage(chatProvider, currentUserId);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoTranslateMessage(ChatMessage message, Color primaryPurple) {
    final messageText = message.contentText ?? '';
    print('_autoTranslateMessage called for: $messageText'); // Debug

    // Simulate API translation with dummy data
    String translation;
    switch (messageText.toLowerCase()) {
      case 'hello! how are you today?':
        translation = 'こんにちは！今日はどうですか？';
        break;
      case 'i like to study english very much.':
        translation = '私は英語を勉強するのがとても好きです。';
        break;
      default:
        translation = 'This is a dummy translation of: $messageText';
    }

    setState(() {
      _translatedMessages.add(message.id);
      _messageTranslations[message.id] = translation;
    });

    print('Translation added: $translation'); // Debug

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.chatMessageTranslated}\n${translation.length > 30 ? translation.substring(0, 30) + '...' : translation}',
        ),
        backgroundColor: primaryPurple,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
                hintText: AppLocalizations.of(context)!.enterCorrection,
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
            onPressed: () {
              if (correctionController.text.trim().isNotEmpty) {
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
                  ),
                );
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

  void _sendMessage(ChatProvider chatProvider, String currentUserId) async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final success = await chatProvider.sendMessage(
      messageText,
      senderId: currentUserId,
    );

    if (success) {
      // Auto scroll to bottom after sending
      _scrollToBottom();
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${chatProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatLastSeen(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return AppLocalizations.of(context)!.chatTimestampDaysAgo(diff.inDays);
    } else if (diff.inHours > 0) {
      return AppLocalizations.of(context)!.chatTimestampHoursAgo(diff.inHours);
    } else {
      return AppLocalizations.of(
        context,
      )!.chatTimestampMinutesAgo(diff.inMinutes);
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
