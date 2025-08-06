import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

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
    },
    {
      'id': 'msg_2',
      'name': 'John Doe',
      'role': 'instructor',
      'text':
          'Welcome everyone! I\'m thrilled to guide you through this learning experience.',
      'timestamp': '2025-07-20 10:45 AM',
      'avatar': null,
    },
    {
      'id': 'msg_3',
      'name': 'Alex Rodriguez',
      'role': 'learner',
      'text':
          'Quick question - will the session recordings be available immediately?',
      'timestamp': '2025-07-22 2:15 PM',
      'avatar': null,
    },
  ];

  final List<Map<String, dynamic>> _enrolledMembers = [
    {
      'id': 'instructor_1',
      'name': 'John Doe',
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
      'name': 'Alex Rodriguez',
      'role': 'learner',
      'avatar': null,
      'joinDate': '2025-07-19',
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

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(12),
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
                      AppLocalizations.of(context)!.courseDiscussion,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_enrolledMembers.length} enrolled members',
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
                                      'Instructor',
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
                          ? Color(0xFF7A54FF)
                          : Color(0xFF7A54FF).withOpacity(0.7),
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
                          Icon(
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
                            ? Color(0xFF7A54FF)
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
