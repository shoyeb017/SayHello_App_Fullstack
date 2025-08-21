import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/group_chat_provider.dart';
import '../../../../../models/group_chat_message.dart';

class GroupChatTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const GroupChatTab({super.key, required this.course});

  @override
  State<GroupChatTab> createState() => _GroupChatTabState();
}

class _GroupChatTabState extends State<GroupChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // For demo purposes - in real app, get from auth service
  final String _currentUserId = 'learner_001';
  final String _currentUserName = 'Student';

  // Mock enrolled members data - in real app, get from course service
  final List<Map<String, dynamic>> _enrolledMembers = [
    {
      'id': 'instructor_1',
      'name': 'Dr. Smith',
      'role': 'instructor',
      'avatar': null,
      'joinDate': '2025-07-15',
    },
    {
      'id': 'learner_1',
      'name': 'Sarah Chen',
      'role': 'learner',
      'avatar': null,
      'joinDate': '2025-07-18',
    },
    {
      'id': 'learner_2',
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
      final provider = context.read<GroupChatProvider>();
      provider.loadMessages(courseId);
      provider.subscribeToRealTimeUpdates(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final localizations = AppLocalizations.of(context)!;

    // Consistent theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    return Consumer<GroupChatProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.all(12),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.8),
                          primaryColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chat, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.courseDiscussion,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${provider.messageCount} messages',
                          style: TextStyle(fontSize: 11, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    onPressed: () => _refreshMessages(),
                    icon: Icon(Icons.refresh, color: primaryColor, size: 18),
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: subTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start the conversation!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: provider.messages.length,
                              itemBuilder: (context, index) {
                                final message = provider.messages[index];
                                return _buildMessageBubble(message, primaryColor, textColor, subTextColor, isDark);
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
              padding: const EdgeInsets.all(12),
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
                        hintText: localizations.typeYourMessage,
                        hintStyle: TextStyle(color: subTextColor, fontSize: 12),
                        prefixIcon: Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(color: textColor, fontSize: 12),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !provider.isSending,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FloatingActionButton.small(
                    onPressed: provider.isSending ? null : _sendMessage,
                    backgroundColor: provider.isSending 
                        ? Colors.grey 
                        : primaryColor,
                    child: provider.isSending
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 16),
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
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isInstructor = message['role'] == 'instructor';
              final isMe = message['name'] == 'You';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isInstructor
                          ? primaryColor
                          : primaryColor.withOpacity(0.7),
                      child: Text(
                        (message['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Message Content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? primaryColor.withOpacity(0.1)
                              : cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          message['name'].toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isInstructor
                                                ? primaryColor
                                                : textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isInstructor) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isInstructor)
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
                                      AppLocalizations.of(
                                        context,
                                      )!.instructorRole,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Message Text
                            Text(
                              message['text'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Footer - Only timestamp
                            Row(
                              children: [
                                Text(
                                  message['timestamp'].toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Input Section
        Container(
          padding: const EdgeInsets.all(12),
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
                    hintText: AppLocalizations.of(context)!.typeYourMessage,
                    hintStyle: TextStyle(color: subTextColor, fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  style: TextStyle(color: textColor, fontSize: 12),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 6),
              FloatingActionButton.small(
                onPressed: _sendMessage,
                backgroundColor: primaryColor,
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final courseId = widget.course['id']?.toString();
    if (courseId == null) return;

    final messageText = _controller.text.trim();
    _controller.clear();

    final success = await context.read<GroupChatProvider>().sendMessage(
      courseId: courseId,
      senderId: _currentUserId,
      senderType: 'learner',
      contentText: messageText,
    );

    if (success) {
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
                            message.senderName ?? (isInstructor ? 'Instructor' : 'Student'),
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
                    style: TextStyle(
                      fontSize: 10,
                      color: subTextColor,
                    ),
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

  @override
  void dispose() {
    final provider = context.read<GroupChatProvider>();
    provider.unsubscribeFromRealTimeUpdates();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
