import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/group_chat_provider.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../models/group_chat.dart';
import '../../../../../models/learner.dart';

class GroupChatTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const GroupChatTab({super.key, required this.course});

  @override
  State<GroupChatTab> createState() => _GroupChatTabState();
}

class _GroupChatTabState extends State<GroupChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Provider reference for safe disposal
  GroupChatProvider? _groupChatProvider;
  int _previousMessageCount = 0;

  // Get current user data from auth
  String get _currentUserId {
    final authProvider = context.read<AuthProvider>();
    final learner = authProvider.currentUser as Learner?;
    return learner?.id ?? '';
  }

  String get _currentUserName {
    final authProvider = context.read<AuthProvider>();
    final learner = authProvider.currentUser as Learner?;
    return learner?.name ?? 'Student';
  }

  // Mock enrolled members data - in real app, get from course service
  final List<Map<String, dynamic>> _enrolledMembers = [
    {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'name': 'Dr. Smith',
      'role': 'instructor',
      'avatar': null,
      'joinDate': '2025-07-15',
    },
    {
      'id': '123e4567-e89b-12d3-a456-426614174001',
      'name': 'Sarah Chen',
      'role': 'learner',
      'avatar': null,
      'joinDate': '2025-07-18',
    },
    {
      'id': '123e4567-e89b-12d3-a456-426614174002',
      'name': 'Mike Johnson',
      'role': 'learner',
      'avatar': null,
      'joinDate': '2025-07-19',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  void _loadMessages() {
    final courseId = widget.course['id']?.toString();
    if (courseId != null) {
      _groupChatProvider = context.read<GroupChatProvider>();
      _groupChatProvider!.loadMessages(courseId);
      _groupChatProvider!.subscribeToRealTimeUpdates(courseId);

      // Initialize previous message count and auto-scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previousMessageCount = _groupChatProvider?.messages.length ?? 0;
        // Auto-scroll to bottom to show latest messages (instant for initial load)
        _scrollToBottomInstantly();
      });
    }
  }

  void _autoScrollToBottom() {
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

  void _scrollToBottomInstantly() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a small delay to ensure ListView is fully built
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Consumer<GroupChatProvider>(
      builder: (context, provider, child) {
        // Auto-scroll to bottom when new messages arrive
        final currentMessageCount = provider.messages.length;
        if (currentMessageCount > _previousMessageCount &&
            _previousMessageCount > 0) {
          _autoScrollToBottom();
        }
        // Also auto-scroll when messages are first loaded (initial load) - use instant scroll
        else if (currentMessageCount > 0 &&
            _previousMessageCount == 0 &&
            !provider.isLoading) {
          _scrollToBottomInstantly();
        }
        _previousMessageCount = currentMessageCount;

        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          body: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Group Chat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            provider.isLoading
                                ? 'Loading messages...'
                                : '${provider.messageCount} messages',
                            style: TextStyle(fontSize: 11, color: subTextColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEnrolledMembers(context),
                      icon: Icon(Icons.people, color: primaryColor, size: 20),
                    ),
                  ],
                ),
              ),

              // Messages List
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${provider.error}',
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshMessages,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : provider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: subTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation with your classmates and instructor',
                              style: TextStyle(
                                fontSize: 14,
                                color: subTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _refreshMessages(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: provider.messages.length,
                          itemBuilder: (context, index) {
                            final message = provider.messages[index];
                            return _buildMessageBubble(
                              message,
                              primaryColor,
                              textColor,
                              subTextColor,
                              isDark,
                            );
                          },
                        ),
                      ),
              ),

              // Message Input
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: subTextColor,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[700]
                              : Colors.grey[100],
                        ),
                        style: TextStyle(color: textColor, fontSize: 14),
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _controller.text.trim().isEmpty
                              ? Colors.grey
                              : primaryColor,
                        ),
                        child: provider.isSending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    GroupChatMessage message,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    final isMe = message.senderId == _currentUserId;
    final isInstructor = message.isFromInstructor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // Avatar
            CircleAvatar(
              radius: 14,
              backgroundColor: isInstructor
                  ? primaryColor
                  : primaryColor.withOpacity(0.2),
              child: isInstructor
                  ? const Icon(Icons.school, color: Colors.white, size: 12)
                  : Text(
                      (message.senderName ?? 'U').substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],

          // Message Content
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe
                    ? primaryColor.withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
                border: isMe
                    ? Border.all(color: primaryColor.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and role indicator
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Text(
                            message.senderName ??
                                (isInstructor ? 'Instructor' : 'Student'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isInstructor ? primaryColor : textColor,
                            ),
                          ),
                          if (isInstructor) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Instructor',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Message Text
                  Text(
                    message.contentText,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Footer - Only timestamp
                  Text(
                    message.getFormattedTime(),
                    style: TextStyle(fontSize: 10, color: subTextColor),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            // User Avatar
            CircleAvatar(
              radius: 14,
              backgroundColor: primaryColor.withOpacity(0.2),
              child: Text(
                _currentUserName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _refreshMessages() {
    final courseId = widget.course['id']?.toString();
    if (courseId != null) {
      context.read<GroupChatProvider>().refreshMessages(courseId);
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final courseId = widget.course['id']?.toString();
    if (courseId == null) return;

    // Check if user is authenticated
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send messages')),
      );
      return;
    }

    final messageText = _controller.text.trim();
    _controller.clear();

    await context.read<GroupChatProvider>().sendMessage(
      courseId: courseId,
      senderId: _currentUserId,
      senderType: 'learner',
      contentText: messageText,
    );

    // Auto-scroll is now handled automatically in the Consumer
    // when the provider notifies listeners of the new message
  }

  void _showEnrolledMembers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enrolled Members (${_enrolledMembers.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(_enrolledMembers
                .map(
                  (member) => ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: member['role'] == 'instructor'
                          ? const Color(0xFF7A54FF)
                          : const Color(0xFF7A54FF).withOpacity(0.7),
                      child: Text(
                        (member['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            member['name'].toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (member['role'] == 'instructor') ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF7A54FF),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      member['role'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: member['role'] == 'instructor'
                            ? const Color(0xFF7A54FF)
                            : Colors.grey,
                      ),
                    ),
                  ),
                )
                .toList()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupChatProvider?.unsubscribeFromRealTimeUpdates();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
