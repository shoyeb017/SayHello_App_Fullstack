import 'package:flutter/material.dart';

// Models for chat data
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
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? translatedText;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final String? correctedText;
  final String? correctionNote;
  final bool isCorrection;
  final List<String> reactions;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.translatedText,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.correctedText,
    this.correctionNote,
    this.isCorrection = false,
    this.reactions = const [],
  });
}

enum MessageType { text, sticker, voice, image }

class ChatSummary {
  final String chatId;
  final ChatUser user;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;

  ChatSummary({
    required this.chatId,
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
  });
}

// Main Chat Feed Page (Summary List)
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample chat data - replicating HelloTalk style
  final List<ChatSummary> _chatSummaries = [
    ChatSummary(
      chatId: 'chat_001',
      user: ChatUser(
        id: 'user_001',
        name: 'ちょこ',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        country: 'Japan',
        flag: '🇯🇵',
        age: 24,
        gender: 'F',
        isOnline: true,
        lastSeen: DateTime.now(),
        interests: ['Scorpio', '漫画', 'Anime'],
        nativeLanguage: 'Japanese',
        learningLanguage: 'English',
      ),
      lastMessage: 'Hello! How are you today? 😊',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 2,
    ),
    ChatSummary(
      chatId: 'chat_002',
      user: ChatUser(
        id: 'user_002',
        name: 'Marco',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        country: 'Italy',
        flag: '🇮🇹',
        age: 28,
        gender: 'M',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        interests: ['Football', 'Travel', 'Food'],
        nativeLanguage: 'Italian',
        learningLanguage: 'English',
      ),
      lastMessage: 'Ciao! Want to practice conversation?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
    ),
    ChatSummary(
      chatId: 'chat_003',
      user: ChatUser(
        id: 'user_003',
        name: '민지',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        country: 'South Korea',
        flag: '🇰🇷',
        age: 22,
        gender: 'F',
        isOnline: true,
        lastSeen: DateTime.now(),
        interests: ['K-pop', 'Coffee', 'Art'],
        nativeLanguage: 'Korean',
        learningLanguage: 'English',
      ),
      lastMessage: '안녕하세요! Nice to meet you!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
    ),
    ChatSummary(
      chatId: 'chat_004',
      user: ChatUser(
        id: 'user_004',
        name: 'Isabella',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        country: 'Spain',
        flag: '🇪🇸',
        age: 26,
        gender: 'F',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 5)),
        interests: ['Dancing', 'Music', 'Travel'],
        nativeLanguage: 'Spanish',
        learningLanguage: 'English',
      ),
      lastMessage: '¡Hola! ¿Cómo estás?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 6)),
      unreadCount: 0,
    ),
    ChatSummary(
      chatId: 'chat_005',
      user: ChatUser(
        id: 'user_005',
        name: 'Ahmed',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        country: 'Egypt',
        flag: '🇪🇬',
        age: 30,
        gender: 'M',
        isOnline: true,
        lastSeen: DateTime.now(),
        interests: ['History', 'Books', 'Coffee'],
        nativeLanguage: 'Arabic',
        learningLanguage: 'English',
      ),
      lastMessage: 'السلام عليكم! Nice to meet you!',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 45)),
      unreadCount: 3,
    ),
  ];

  List<ChatSummary> get _filteredChats {
    if (_searchQuery.isEmpty) return _chatSummaries;
    return _chatSummaries
        .where(
          (chat) =>
              chat.user.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              chat.user.country.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = const Color(0xFF7a54ff);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            // Profile image (current user)
            CircleAvatar(
              radius: 20,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=99',
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.video_call, color: primaryPurple, size: 28),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Video call feature coming soon!'),
                    backgroundColor: primaryPurple,
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: primaryPurple,
                size: 24,
              ),
              onPressed: () {
                _showSettingsBottomSheet(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return _buildChatSummaryItem(
                  context,
                  chat,
                  isDark,
                  primaryPurple,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSummaryItem(
    BuildContext context,
    ChatSummary chat,
    bool isDark,
    Color primaryPurple,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(user: chat.user),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile Picture with Flag
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat.user.avatarUrl),
                ),
                // Online status indicator
                if (chat.user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
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
                // Flag overlay
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat.user.flag,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Name
                      Text(
                        chat.user.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Age Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: chat.user.gender == 'F'
                              ? Colors.pink.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${chat.user.gender}${chat.user.age}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: chat.user.gender == 'F'
                                ? Colors.pink.shade600
                                : Colors.blue.shade600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Timestamp
                      Text(
                        _formatMessageTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Country
                  Text(
                    chat.user.country,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Last Message
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Interest Tags
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: chat.user.interests.take(3).map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryPurple.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 10,
                            color: primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Unread Badge
            if (chat.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = const Color(0xFF7a54ff);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chat Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsItem(
              context,
              Icons.notifications,
              'Notifications',
              primaryPurple,
            ),
            _buildSettingsItem(
              context,
              Icons.block,
              'Blocked Users',
              primaryPurple,
            ),
            _buildSettingsItem(
              context,
              Icons.privacy_tip,
              'Privacy',
              primaryPurple,
            ),
            _buildSettingsItem(
              context,
              Icons.help,
              'Help & Support',
              primaryPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    Color primaryPurple,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: primaryPurple),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title feature coming soon!'),
            backgroundColor: primaryPurple,
          ),
        );
      },
    );
  }
}

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
  bool _showTranslation = true;
  String? _selectedMessageForCorrection;

  // Sample messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg_001',
      senderId: 'user_001',
      text: 'Hello! How are you today?',
      translatedText: 'こんにちは！今日はどうですか？',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg_002',
      senderId: 'current_user',
      text: 'I am good! Thanks for asking.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg_003',
      senderId: 'user_001',
      text: 'I like to study English very much.',
      translatedText: '私は英語を勉強するのがとても好きです。',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
      correctedText: 'I like studying English very much.',
      correctionNote: 'Use "studying" (gerund) instead of "to study" here.',
      isCorrection: true,
    ),
    ChatMessage(
      id: 'msg_004',
      senderId: 'current_user',
      text: 'That\'s great! Keep practicing! 😊',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg_005',
      senderId: 'user_001',
      text: '👋',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: MessageType.sticker,
      isRead: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                  backgroundImage: NetworkImage(widget.user.avatarUrl),
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
                        ? 'Online'
                        : 'Last seen ${_formatLastSeen(widget.user.lastSeen)}',
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
          IconButton(
            icon: Icon(Icons.video_call, color: primaryPurple),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Starting video call...'),
                  backgroundColor: primaryPurple,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Translation Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: primaryPurple.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.translate, color: primaryPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Auto-translate',
                  style: TextStyle(
                    color: primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showTranslation,
                  onChanged: (value) {
                    setState(() {
                      _showTranslation = value;
                    });
                  },
                  activeColor: primaryPurple,
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message.senderId == 'current_user';

                return _buildMessageItem(
                  context,
                  message,
                  isCurrentUser,
                  isDark,
                  primaryPurple,
                );
              },
            ),
          ),

          // Message Input
          _buildMessageInput(context, isDark, primaryPurple),
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
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.user.avatarUrl),
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
                GestureDetector(
                  onTap: () {
                    if (!isCurrentUser && message.type == MessageType.text) {
                      setState(() {
                        _selectedMessageForCorrection =
                            _selectedMessageForCorrection == message.id
                            ? null
                            : message.id;
                      });
                    }
                  },
                  child: Container(
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
                        if (message.type == MessageType.sticker)
                          Text(
                            message.text,
                            style: const TextStyle(fontSize: 48),
                          )
                        else
                          Text(
                            message.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: isCurrentUser
                                  ? Colors.black
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),

                        // Translation
                        if (!isCurrentUser &&
                            message.translatedText != null &&
                            _showTranslation) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 14,
                                color: primaryPurple,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  message.translatedText!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: primaryPurple,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Correction
                        if (message.isCorrection &&
                            message.correctedText != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Correction:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.correctedText!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (message.correctionNote != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    message.correctionNote!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Correction Options (when message is selected)
                if (_selectedMessageForCorrection == message.id &&
                    !isCurrentUser &&
                    message.type == MessageType.text)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help correct this message:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: message.text,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: primaryPurple,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedMessageForCorrection = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Correction sent!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedMessageForCorrection = null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Add a note (optional)...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryPurple),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Timestamp & Read Status
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatMessageTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (isCurrentUser && message.isRead)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Read',
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
            // Attachment button
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              onPressed: () {
                _showAttachmentOptions(context, primaryPurple);
              },
            ),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
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
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      onPressed: () {
                        // Show emoji picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Emoji picker coming soon!'),
                            backgroundColor: primaryPurple,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send/Voice button
            Container(
              decoration: BoxDecoration(
                color: primaryPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _messageController.text.isNotEmpty ? Icons.send : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _sendMessage();
                  } else {
                    // Start voice recording
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Voice recording coming soon!'),
                        backgroundColor: primaryPurple,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Auto scroll to bottom
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

  String _formatLastSeen(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inMinutes} minutes ago';
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

  void _showChatOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = const Color(0xFF7a54ff);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chat Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildChatOptionItem(
              context,
              Icons.person,
              'View Profile',
              primaryPurple,
            ),
            _buildChatOptionItem(
              context,
              Icons.volume_off,
              'Mute Chat',
              primaryPurple,
            ),
            _buildChatOptionItem(
              context,
              Icons.block,
              'Block User',
              Colors.red,
            ),
            _buildChatOptionItem(context, Icons.report, 'Report', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOptionItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title feature coming soon!'),
            backgroundColor: color,
          ),
        );
      },
    );
  }

  void _showAttachmentOptions(BuildContext context, Color primaryPurple) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Send Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  Icons.photo,
                  'Photo',
                  primaryPurple,
                ),
                _buildAttachmentOption(
                  context,
                  Icons.videocam,
                  'Video',
                  primaryPurple,
                ),
                _buildAttachmentOption(
                  context,
                  Icons.insert_drive_file,
                  'File',
                  primaryPurple,
                ),
                _buildAttachmentOption(
                  context,
                  Icons.location_on,
                  'Location',
                  primaryPurple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    Color primaryPurple,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label attachment coming soon!'),
            backgroundColor: primaryPurple,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primaryPurple.withOpacity(0.3)),
            ),
            child: Icon(icon, color: primaryPurple, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
