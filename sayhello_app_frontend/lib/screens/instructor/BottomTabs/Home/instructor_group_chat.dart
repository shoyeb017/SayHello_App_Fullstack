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

  // Enhanced chat messages following learner context
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'msg_1',
      'name': 'Emma Watson',
      'role': 'learner',
      'text': 'Good morning! Ready for today\'s Flutter session 💻',
      'timestamp': '2025-08-07 9:15 AM',
      'avatar': null,
    },
    {
      'id': 'msg_2',
      'name': 'You',
      'role': 'instructor',
      'text':
          'Good morning everyone! Today we\'ll cover advanced state management concepts.',
      'timestamp': '2025-08-07 9:20 AM',
      'avatar': null,
    },
    {
      'id': 'msg_3',
      'name': 'Mike Johnson',
      'role': 'learner',
      'text': 'Will we be using Provider or Riverpod for state management?',
      'timestamp': '2025-08-07 9:25 AM',
      'avatar': null,
    },
    {
      'id': 'msg_4',
      'name': 'Sarah Williams',
      'role': 'learner',
      'text':
          'Thanks for the clear explanation yesterday! Really helped with my project.',
      'timestamp': '2025-08-07 10:10 AM',
      'avatar': null,
    },
  ];

  final List<Map<String, dynamic>> _enrolledStudents = [
    {
      'id': 'learner_1',
      'name': 'Emma Watson',
      'role': 'learner',
      'avatar': null,
      'isOnline': true,
    },
    {
      'id': 'learner_2',
      'name': 'Mike Johnson',
      'role': 'learner',
      'avatar': null,
      'isOnline': true,
    },
    {
      'id': 'learner_3',
      'name': 'Sarah Williams',
      'role': 'learner',
      'avatar': null,
      'isOnline': false,
    },
    {
      'id': 'learner_4',
      'name': 'David Chen',
      'role': 'learner',
      'avatar': null,
      'isOnline': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);

    // Consistent theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    // Get online students count
    final onlineCount = _enrolledStudents
        .where((s) => s['isOnline'] == true)
        .length;

    return Column(
      children: [
        // Instructor Chat Header - Different from learner
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
                child: const Icon(Icons.school, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructor Panel - ${widget.course['title']}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$onlineCount online • ${_enrolledStudents.length} total students',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'INSTRUCTOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Messages List - Similar to learner but with instructor perspective
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isMe = message['name'] == 'You';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      // Student Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Text(
                          (message['name'] as String)
                              .substring(0, 1)
                              .toUpperCase(),
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
                                      message['name'].toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.person,
                                      size: 12,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),

                            // Message Text
                            Text(
                              message['text'].toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: isMe ? Colors.white : textColor,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Footer with timestamp
                            Text(
                              message['timestamp'].toString(),
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
                      // Instructor Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Input Section - Instructor style
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
                    hintText: 'Message your students...',
                    hintStyle: TextStyle(color: subTextColor, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.school,
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
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: _sendMessage,
                backgroundColor: primaryColor,
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
        'role': 'instructor',
        'text': _controller.text.trim(),
        'timestamp': _formatTimestamp(DateTime.now()),
        'avatar': null,
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
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour;
    return '${dateTime.month}/${dateTime.day} ${displayHour}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
