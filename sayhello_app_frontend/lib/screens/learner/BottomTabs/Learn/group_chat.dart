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

  // Enhanced dynamic chat data
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
    },
    {
      'id': 'msg_2',
      'name': 'John Doe',
      'role': 'instructor',
      'text':
          'Welcome everyone! I\'m thrilled to guide you through this learning experience.',
      'timestamp': '2025-07-20 10:45 AM',
      'avatar': null,
      'reactions': ['❤️', '👨‍🏫'],
      'reactionCount': {'❤️': 5, '👨‍🏫': 3},
    },
    {
      'id': 'msg_3',
      'name': 'Alex Rodriguez',
      'role': 'learner',
      'text':
          'Quick question - will the session recordings be available immediately?',
      'timestamp': '2025-07-22 2:15 PM',
      'avatar': null,
      'reactions': ['🤔'],
      'reactionCount': {'🤔': 2},
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
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Consistent theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    final onlineCount = _participants
        .where((p) => p['status'] == 'online')
        .length;

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: double.infinity),
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
                child: const Icon(Icons.chat, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Discussion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$onlineCount online • ${_participants.length} participants',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showParticipants(context),
                icon: const Icon(Icons.people, color: Colors.purple),
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
              final isInstructor = message['role'] == 'instructor';
              final isMe = message['name'] == 'You';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isInstructor
                          ? Colors.purple
                          : Colors.teal,
                      child: Text(
                        (message['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Message Content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.purple.withOpacity(0.1)
                              : cardColor,
                          borderRadius: BorderRadius.circular(12),
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
                                  child: Text(
                                    message['name'].toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isInstructor
                                          ? Colors.purple
                                          : textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isInstructor)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Instructor',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Message Text
                            Text(
                              message['text'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Footer
                            Row(
                              children: [
                                Text(
                                  message['timestamp'].toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subTextColor,
                                  ),
                                ),
                                const Spacer(),
                                if (message['reactions'] != null &&
                                    (message['reactions'] as List).isNotEmpty)
                                  Wrap(
                                    spacing: 4,
                                    children: (message['reactions'] as List).map((
                                      reaction,
                                    ) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '$reaction ${message['reactionCount'][reaction] ?? 1}',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }).toList(),
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
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: subTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  style: TextStyle(color: textColor),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: _sendMessage,
                backgroundColor: Colors.purple,
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  void _showParticipants(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Participants (${_participants.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_participants
                .map(
                  (participant) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: participant['role'] == 'instructor'
                          ? Colors.purple
                          : Colors.teal,
                      child: Text(
                        (participant['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(participant['name'].toString()),
                    subtitle: Text(participant['role'].toString()),
                    trailing: Icon(
                      Icons.circle,
                      size: 12,
                      color: _getStatusColor(participant['status']),
                    ),
                  ),
                )
                .toList()),
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
