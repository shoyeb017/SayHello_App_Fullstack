import 'package:flutter/material.dart';

class InstructorGroupChatTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorGroupChatTab({super.key, required this.course});

  @override
  State<InstructorGroupChatTab> createState() => _InstructorGroupChatTabState();
}

class _InstructorGroupChatTabState extends State<InstructorGroupChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Dynamic message data - replace with backend API later
  List<Map<String, dynamic>> _messages = [
    {
      'id': 'msg_001',
      'senderId': 'student_001',
      'senderName': 'Alice Johnson',
      'senderRole': 'student',
      'message': 'Hello everyone! Excited to start this course 😊',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': true,
    },
    {
      'id': 'msg_002',
      'senderId': 'instructor',
      'senderName': 'You',
      'senderRole': 'instructor',
      'message':
          'Welcome Alice! Great to have you here. Feel free to ask any questions.',
      'timestamp': DateTime.now().subtract(
        const Duration(hours: 1, minutes: 45),
      ),
      'isRead': true,
    },
    {
      'id': 'msg_003',
      'senderId': 'student_002',
      'senderName': 'Bob Wilson',
      'senderRole': 'student',
      'message': 'When will the recorded session be available?',
      'timestamp': DateTime.now().subtract(
        const Duration(hours: 1, minutes: 30),
      ),
      'isRead': true,
    },
    {
      'id': 'msg_004',
      'senderId': 'instructor',
      'senderName': 'You',
      'senderRole': 'instructor',
      'message':
          'Hi Bob! The recorded session will be uploaded within 24 hours after each live session.',
      'timestamp': DateTime.now().subtract(
        const Duration(hours: 1, minutes: 15),
      ),
      'isRead': true,
    },
    {
      'id': 'msg_005',
      'senderId': 'student_003',
      'senderName': 'Carol Smith',
      'senderRole': 'student',
      'message': 'Thank you for the detailed explanation in today\'s session!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
    },
  ];

  // Online students
  final List<Map<String, dynamic>> _onlineStudents = [
    {
      'id': 'student_001',
      'name': 'Alice Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'id': 'student_002',
      'name': 'Bob Wilson',
      'avatar': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'id': 'student_003',
      'name': 'Carol Smith',
      'avatar': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'id': 'student_004',
      'name': 'David Brown',
      'avatar': 'https://i.pravatar.cc/150?img=4',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'senderId': 'instructor',
        'senderName': 'You',
        'senderRole': 'instructor',
        'message': _controller.text.trim(),
        'timestamp': DateTime.now(),
        'isRead': true,
      });
      _controller.clear();
    });

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Online Students Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[50],
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: const Color(0xFF7A54FF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Online Students (${_onlineStudents.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showChatSettings,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _onlineStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final student = _onlineStudents[index];
                    final firstName = student['name'].split(' ')[0];
                    return SizedBox(
                      width: 35,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(student['avatar']),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            firstName.length > 6
                                ? '${firstName.substring(0, 6)}.'
                                : firstName,
                            style: TextStyle(
                              fontSize: 8,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildMessageBubble(_messages[index], isDark);
            },
          ),
        ),

        // Message Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message to your students...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF7A54FF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark) {
    final isInstructor = message['senderRole'] == 'instructor';
    final timestamp = message['timestamp'] as DateTime;

    return Align(
      alignment: isInstructor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isInstructor
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isInstructor) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message['senderName'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7A54FF),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isInstructor
                    ? const Color(0xFF7A54FF)
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isInstructor ? const Radius.circular(4) : null,
                  bottomLeft: !isInstructor ? const Radius.circular(4) : null,
                ),
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message['message'],
                      style: TextStyle(
                        color: isInstructor
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        fontSize: 14,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(timestamp),
                      style: TextStyle(
                        color: isInstructor
                            ? Colors.white70
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showChatSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Chat Settings',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.notification_add,
                    color: Color(0xFF7A54FF),
                  ),
                  title: Text(
                    'Send Announcement',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAnnouncementDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.people_outline,
                    color: Color(0xFF7A54FF),
                  ),
                  title: Text(
                    'Manage Participants',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to participants management
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Color(0xFF7A54FF)),
                  title: Text(
                    'Moderation Settings',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to moderation settings
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF7A54FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAnnouncementDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final announcementController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Send Announcement',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: TextField(
                controller: announcementController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Type your announcement...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (announcementController.text.trim().isNotEmpty) {
                  // Send announcement
                  setState(() {
                    _messages.add({
                      'id':
                          'announcement_${DateTime.now().millisecondsSinceEpoch}',
                      'senderId': 'instructor',
                      'senderName': 'Announcement',
                      'senderRole': 'announcement',
                      'message': '📢 ${announcementController.text.trim()}',
                      'timestamp': DateTime.now(),
                      'isRead': true,
                    });
                  });
                  Navigator.of(context).pop();
                  _scrollToBottom();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
              ),
              child: const Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
