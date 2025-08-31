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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);

    // Consistent theme colors
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = Theme.of(context).cardColor;

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

        return Column(
          children: [
            // Learner Chat Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group Chat - ${widget.course['title']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${provider.messageCount} messages',
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    onPressed: () => _refreshMessages(),
                    icon: Icon(Icons.refresh, color: primaryColor, size: 20),
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
                            child: Text('Retry'),
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
                            style: TextStyle(fontSize: 16, color: subTextColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with your classmates and instructor',
                            style: TextStyle(fontSize: 14, color: subTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
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

            // Error display
            if (provider.error != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.clearError(),
                      icon: Icon(Icons.close, color: Colors.red, size: 16),
                    ),
                  ],
                ),
              ),

            // Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
                        hintStyle: TextStyle(color: subTextColor, fontSize: 13),
                        prefixIcon: Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: TextStyle(color: textColor, fontSize: 13),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !provider.isSending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: provider.isSending ? null : _sendMessage,
                    backgroundColor: provider.isSending
                        ? Colors.grey
                        : primaryColor,
                    child: provider.isSending
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // Student/Instructor Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: message.isFromInstructor
                  ? primaryColor
                  : primaryColor.withOpacity(0.2),
              child: message.isFromInstructor
                  ? const Icon(Icons.school, color: Colors.white, size: 12)
                  : Text(
                      (message.senderName ?? 'S').substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
          ],

          // Message Content
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? primaryColor
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and role indicator
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            message.senderName ??
                                (message.isFromInstructor
                                    ? 'Instructor'
                                    : 'Student'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: message.isFromInstructor
                                  ? primaryColor
                                  : textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            message.isFromInstructor
                                ? Icons.school
                                : Icons.person,
                            size: 12,
                            color: message.isFromInstructor
                                ? primaryColor
                                : textColor,
                          ),
                        ],
                      ),
                    ),

                  // Message Text
                  Text(
                    message.contentText,
                    style: TextStyle(
                      fontSize: 13,
                      color: isMe ? Colors.white : textColor,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Footer with timestamp
                  Text(
                    message.getFormattedTime(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 10),
            // Student Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor.withOpacity(0.2),
              child: Text(
                _currentUserName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
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

  @override
  void dispose() {
    _groupChatProvider?.unsubscribeFromRealTimeUpdates();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
