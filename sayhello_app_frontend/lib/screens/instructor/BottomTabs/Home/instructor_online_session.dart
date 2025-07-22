import 'package:flutter/material.dart';

class InstructorOnlineSessionTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorOnlineSessionTab({super.key, required this.course});

  @override
  State<InstructorOnlineSessionTab> createState() =>
      _InstructorOnlineSessionTabState();
}

class _InstructorOnlineSessionTabState
    extends State<InstructorOnlineSessionTab> {
  // Dynamic session data - replace with backend API later
  List<Map<String, dynamic>> _sessions = [
    {
      'id': 'session_001',
      'title': 'Introduction to Flutter Widgets',
      'platform': 'Zoom',
      'date': '2025-07-25',
      'time': '6:00 PM',
      'duration': '2 hours',
      'link': 'https://zoom.us/j/1234567890',
      'status': 'scheduled',
      'attendees': 23,
      'maxAttendees': 50,
    },
    {
      'id': 'session_002',
      'title': 'State Management Deep Dive',
      'platform': 'Google Meet',
      'date': '2025-07-27',
      'time': '4:30 PM',
      'duration': '1.5 hours',
      'link': 'https://meet.google.com/abc-defg-hij',
      'status': 'scheduled',
      'attendees': 18,
      'maxAttendees': 50,
    },
    {
      'id': 'session_003',
      'title': 'Building Your First App',
      'platform': 'Zoom',
      'date': '2025-07-20',
      'time': '6:00 PM',
      'duration': '2 hours',
      'link': 'https://zoom.us/j/0987654321',
      'status': 'completed',
      'attendees': 45,
      'maxAttendees': 50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Add Session Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddSessionDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Schedule New Session',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Sessions List
        Expanded(
          child: _sessions.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildSessionCard(_sessions[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isDark) {
    final status = session['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session['title'] ?? 'Untitled Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                session['date'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${session['time']} (${session['duration']})',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                session['platform'] == 'Zoom'
                    ? Icons.videocam
                    : Icons.video_call,
                size: 16,
                color: const Color(0xFF7A54FF),
              ),
              const SizedBox(width: 6),
              Text(
                session['platform'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A54FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${session['attendees']}/${session['maxAttendees']} attendees',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              if (status == 'scheduled') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editSession(session),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7A54FF),
                      side: const BorderSide(color: Color(0xFF7A54FF)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startSession(session),
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Start',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A54FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ] else if (status == 'completed') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewSessionReport(session),
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('View Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7A54FF),
                      side: const BorderSide(color: Color(0xFF7A54FF)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_call_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule your first online session',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddSessionDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Schedule Session',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A54FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddSessionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Schedule New Session',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Session scheduling feature coming soon!\n\nThis will include:\n• Date and time selection\n• Platform choice (Zoom/Meet)\n• Session duration\n• Meeting link generation\n• Student notifications',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF7A54FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editSession(Map<String, dynamic> session) {
    // TODO: Implement edit session functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit session feature coming soon!')),
    );
  }

  void _startSession(Map<String, dynamic> session) {
    // TODO: Implement start session functionality (open meeting link)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting session: ${session['title']}')),
    );
  }

  void _viewSessionReport(Map<String, dynamic> session) {
    // TODO: Implement session report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session report feature coming soon!')),
    );
  }
}
