import 'package:flutter/material.dart';

class GroupChatTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const GroupChatTab({super.key, required this.course});

  @override
  State<GroupChatTab> createState() => _GroupChatTabState();
}

class _GroupChatTabState extends State<GroupChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Enhanced dynamic chat data with learner interaction features
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'msg_1',
      'name': 'Sarah Chen',
      'role': 'learner',
      'text':
          'Hi everyone! Excited to start this course journey with you all 🎉',
      'timestamp': '2025-07-20 10:30 AM',
      'avatar': null,
      'reactions': ['👍', '🎉'],
      'reactionCount': {'👍': 3, '🎉': 2},
      'isEdited': false,
      'replyTo': null,
    },
    {
      'id': 'msg_2',
      'name': 'John Doe',
      'role': 'instructor',
      'text':
          'Welcome everyone! I\'m thrilled to guide you through this learning experience. Feel free to ask questions anytime.',
      'timestamp': '2025-07-20 10:45 AM',
      'avatar': null,
      'reactions': ['❤️', '👨‍🏫'],
      'reactionCount': {'❤️': 5, '👨‍🏫': 3},
      'isEdited': false,
      'replyTo': null,
    },
    {
      'id': 'msg_3',
      'name': 'Alex Rodriguez',
      'role': 'learner',
      'text':
          'Quick question - will the session recordings be available immediately after each class?',
      'timestamp': '2025-07-22 2:15 PM',
      'avatar': null,
      'reactions': ['🤔'],
      'reactionCount': {'🤔': 2},
      'isEdited': false,
      'replyTo': null,
    },
    {
      'id': 'msg_4',
      'name': 'John Doe',
      'role': 'instructor',
      'text':
          '@Alex Rodriguez Yes! Recordings will be available within 2 hours after each session ends. You\'ll find them in the Recorded Classes tab.',
      'timestamp': '2025-07-22 2:30 PM',
      'avatar': null,
      'reactions': ['✅', '📹'],
      'reactionCount': {'✅': 4, '📹': 1},
      'isEdited': false,
      'replyTo': 'msg_3',
    },
    {
      'id': 'msg_5',
      'name': 'Maria Santos',
      'role': 'learner',
      'text':
          'The study materials are excellent! Really helpful for understanding the concepts.',
      'timestamp': '2025-07-23 9:20 AM',
      'avatar': null,
      'reactions': ['📚', '💯'],
      'reactionCount': {'📚': 3, '💯': 2},
      'isEdited': false,
      'replyTo': null,
    },
    {
      'id': 'msg_6',
      'name': 'David Kim',
      'role': 'learner',
      'text':
          'Can we schedule some additional practice sessions? I think it would be really beneficial for all of us.',
      'timestamp': '2025-07-23 11:45 AM',
      'avatar': null,
      'reactions': ['💪'],
      'reactionCount': {'💪': 4},
      'isEdited': false,
      'replyTo': null,
    },
  ];

  final List<Map<String, dynamic>> _participants = [
    {
      'id': 'instructor_1',
      'name': 'John Doe',
      'role': 'instructor',
      'status': 'online',
      'avatar': null,
      'joinDate': '2025-07-15',
    },
    {
      'id': 'learner_1',
      'name': 'Sarah Chen',
      'role': 'learner',
      'status': 'online',
      'avatar': null,
      'joinDate': '2025-07-18',
    },
    {
      'id': 'learner_2',
      'name': 'Alex Rodriguez',
      'role': 'learner',
      'status': 'away',
      'avatar': null,
      'joinDate': '2025-07-19',
    },
    {
      'id': 'learner_3',
      'name': 'Maria Santos',
      'role': 'learner',
      'status': 'online',
      'avatar': null,
      'joinDate': '2025-07-20',
    },
    {
      'id': 'learner_4',
      'name': 'David Kim',
      'role': 'learner',
      'status': 'offline',
      'avatar': null,
      'joinDate': '2025-07-21',
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'You',
        'role': 'learner',
        'text': _controller.text.trim(),
        'timestamp': _formatTimestamp(DateTime.now()),
        'avatar': null,
        'reactions': [],
        'reactionCount': {},
        'isEdited': false,
        'replyTo': null,
      });
      _controller.clear();
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

  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final onlineCount = _participants
        .where((p) => p['status'] == 'online')
        .length;

    return Column(
      children: [
        // Chat Header
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
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.purple.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Discussion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '$onlineCount online • ${_participants.length} participants',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showParticipants(context),
                icon: Stack(
                  children: [
                    Icon(Icons.people, color: Colors.purple),
                    if (onlineCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
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
              final isMe = message['name'] == 'You';
              final isInstructor = message['role'] == 'instructor';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isInstructor
                            ? Colors.purple
                            : Colors.blue,
                        child: Text(
                          message['name']![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            Row(
                              children: [
                                Text(
                                  message['name'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isInstructor
                                        ? Colors.purple
                                        : Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                if (isInstructor) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'INSTRUCTOR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.purple.withOpacity(0.9)
                                  : (isInstructor
                                        ? Colors.purple.withOpacity(0.1)
                                        : (isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade100)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message['replyTo'] != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Replying to previous message',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                                Text(
                                  message['text'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : textColor,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message['timestamp'] ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? Colors.white70
                                            : subTextColor,
                                      ),
                                    ),
                                    if (message['isEdited'] == true) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(edited)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                          color: isMe
                                              ? Colors.white60
                                              : subTextColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (message['reactions']?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              children:
                                  (message['reactionCount']
                                          as Map<String, dynamic>)
                                      .entries
                                      .map(
                                        (entry) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${entry.key} ${entry.value}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.purple,
                        child: const Text(
                          'Y',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Message Input
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
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showParticipants(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants (${_participants.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_participants.map(
              (participant) => ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: participant['role'] == 'instructor'
                          ? Colors.purple
                          : Colors.blue,
                      child: Text(
                        participant['name']![0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (participant['status'] == 'online')
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(participant['name'] ?? ''),
                subtitle: Text(participant['role'] ?? ''),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(participant['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    participant['status']?.toUpperCase() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
