import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'date': '2025-08-15',
      'time': '6:00 PM',
      'duration': '2 hours',
      'link': 'https://zoom.us/j/1234567890',
      'password': 'Flutter123',
      'status': 'scheduled',
      'attendees': 23,
      'description': 'Learn the basics of Flutter widgets and state management',
    },
    {
      'id': 'session_002',
      'title': 'State Management Deep Dive',
      'platform': 'Google Meet',
      'date': '2025-08-20',
      'time': '4:30 PM',
      'duration': '1.5 hours',
      'link': 'https://meet.google.com/abc-defg-hij',
      'password': 'StateMan456',
      'status': 'scheduled',
      'attendees': 18,
      'description': 'Advanced state management techniques and best practices',
    },
    {
      'id': 'session_003',
      'title': 'Building Your First App',
      'platform': 'Zoom',
      'date': '2025-07-20',
      'time': '6:00 PM',
      'duration': '2 hours',
      'link': 'https://zoom.us/j/0987654321',
      'password': 'Build789',
      'status': 'completed',
      'attendees': 45,
      'description': 'Hands-on app building session with live coding',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    // Get session statistics
    final totalSessions = _sessions.length;
    final completedSessions = _sessions
        .where((s) => s['status'] == 'completed')
        .length;
    final upcomingSessions = _sessions
        .where((s) => s['status'] == 'scheduled')
        .length;

    return Column(
      children: [
        // Add Session Button - More Visible
        Container(
          margin: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddSessionDialog,
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
              label: const Text(
                'Schedule New Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
            ),
          ),
        ),

        // Compact Header Stats
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.video_camera_front, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Session Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickStat(
                    'Total',
                    totalSessions.toString(),
                    Icons.event,
                    primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickStat(
                    'Done',
                    completedSessions.toString(),
                    Icons.check_circle,
                    primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickStat(
                    'Next',
                    upcomingSessions.toString(),
                    Icons.schedule,
                    primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Sessions List
        Expanded(
          child: _sessions.isEmpty
              ? _buildEmptyState(isDark, primaryColor)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _getSortedSessions().length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sortedSessions = _getSortedSessions();
                    return _buildSessionCard(
                      sortedSessions[index],
                      isDark,
                      primaryColor,
                      textColor,
                      subTextColor,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Method to sort sessions by date and time (newest first)
  List<Map<String, dynamic>> _getSortedSessions() {
    List<Map<String, dynamic>> sortedSessions = List.from(_sessions);

    sortedSessions.sort((a, b) {
      try {
        // Parse dates
        DateTime dateA = DateTime.parse(a['date'] ?? '1970-01-01');
        DateTime dateB = DateTime.parse(b['date'] ?? '1970-01-01');

        // If dates are the same, compare by time
        if (dateA.isAtSameMomentAs(dateB)) {
          // Parse times - handle both 12-hour and 24-hour formats
          TimeOfDay timeA = _parseTime(a['time'] ?? '00:00');
          TimeOfDay timeB = _parseTime(b['time'] ?? '00:00');

          // Convert to minutes for easier comparison
          int minutesA = timeA.hour * 60 + timeA.minute;
          int minutesB = timeB.hour * 60 + timeB.minute;

          return minutesB.compareTo(minutesA); // Newer time first
        }

        return dateB.compareTo(dateA); // Newer date first
      } catch (e) {
        // If parsing fails, maintain original order
        return 0;
      }
    });

    return sortedSessions;
  }

  // Helper method to parse time strings
  TimeOfDay _parseTime(String timeString) {
    try {
      // Remove any extra spaces and convert to lowercase
      String cleanTime = timeString.trim().toLowerCase();

      // Check if it's 12-hour format (contains am/pm)
      bool isPM = cleanTime.contains('pm');
      bool isAM = cleanTime.contains('am');

      // Extract just the time part (remove am/pm)
      String timePart = cleanTime.replaceAll(RegExp(r'[^\d:]'), '');
      List<String> parts = timePart.split(':');

      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        // Convert 12-hour to 24-hour format
        if (isPM && hour != 12) {
          hour += 12;
        } else if (isAM && hour == 12) {
          hour = 0;
        }

        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return default time if parsing fails
    }

    return const TimeOfDay(hour: 0, minute: 0);
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color primaryColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: primaryColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    Map<String, dynamic> session,
    bool isDark,
    Color primaryColor,
    Color? textColor,
    Color? subTextColor,
  ) {
    final status = session['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Header with Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _getPlatformIcon(session['platform']),
                  color: statusColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  session['platform'] ?? '',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteSession(session['id']),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Session Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title'] ?? 'Untitled Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  session['description'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: subTextColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Session Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        session['date'] ?? '',
                        primaryColor,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        session['time'] ?? '',
                        primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.schedule,
                        session['duration'] ?? '',
                        primaryColor,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.people,
                        '${session['attendees']} students',
                        primaryColor,
                      ),
                    ),
                  ],
                ),

                // Session Link and Password (compact)
                if (session['link'] != null) ...[
                  const SizedBox(height: 8),
                  _buildCopyableInfo(
                    'Link',
                    session['link'],
                    Icons.link,
                    primaryColor,
                  ),
                ],
                if (session['password'] != null) ...[
                  const SizedBox(height: 4),
                  _buildCopyableInfo(
                    'Password',
                    session['password'],
                    Icons.lock,
                    primaryColor,
                  ),
                ],

                const SizedBox(height: 8),

                // Action Buttons
                if (status == 'scheduled') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editSession(session),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _startSession(session),
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 14,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Start',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (status == 'completed') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _viewSessionReport(session),
                      icon: const Icon(Icons.analytics, size: 14),
                      label: const Text(
                        'View Report',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, size: 12, color: primaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableInfo(
    String label,
    String value,
    IconData icon,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 12),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value.length > 15 ? '${value.substring(0, 15)}...' : value,
              style: TextStyle(
                fontSize: 10,
                color: primaryColor.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => _copyToClipboard(value, label),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(Icons.copy, color: Colors.white, size: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_call_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions scheduled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your first session',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddSessionDialog,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text(
              'Schedule Session',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'zoom':
        return Icons.video_call;
      case 'google meet':
        return Icons.duo;
      case 'teams':
        return Icons.groups;
      default:
        return Icons.videocam;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFF7A54FF);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied to clipboard'),
            backgroundColor: const Color(0xFF7A54FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy $label'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteSession(String sessionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Delete Session',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete this session? This action cannot be undone.',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _sessions.removeWhere(
                    (session) => session['id'] == sessionId,
                  );
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddSessionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final linkController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedPlatform = 'Zoom';
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    double sessionDuration = 1.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              title: Text(
                'Schedule New Session',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Session Title *',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.title,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Platform Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedPlatform,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Platform *',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.video_call,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      items: ['Zoom', 'Google Meet', 'Teams'].map((
                        String platform,
                      ) {
                        return DropdownMenuItem<String>(
                          value: platform,
                          child: Text(platform, style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPlatform = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme
                                    .copyWith(primary: const Color(0xFF7A54FF)),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: const Color(0xFF7A54FF),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                  : 'Select Date *',
                              style: TextStyle(
                                color: selectedDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time Picker
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme
                                    .copyWith(primary: const Color(0xFF7A54FF)),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: const Color(0xFF7A54FF),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime != null
                                  ? selectedTime!.format(context)
                                  : 'Select Time *',
                              style: TextStyle(
                                color: selectedTime != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Duration Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration: ${sessionDuration.toStringAsFixed(1)} hours',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Icon(
                                  Icons.schedule,
                                  size: 20,
                                  color: const Color(0xFF7A54FF),
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: sessionDuration,
                                  min: 0.5,
                                  max: 4.0,
                                  divisions: 7,
                                  activeColor: const Color(0xFF7A54FF),
                                  inactiveColor: const Color(
                                    0xFF7A54FF,
                                  ).withOpacity(0.3),
                                  onChanged: (double value) {
                                    setState(() {
                                      sessionDuration = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Session Link
                    TextField(
                      controller: linkController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Session Link *',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.link,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextField(
                      controller: passwordController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password (optional)',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null &&
                        linkController.text.isNotEmpty) {
                      final newSession = {
                        'id':
                            'session_${DateTime.now().millisecondsSinceEpoch}',
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'platform': selectedPlatform,
                        'date':
                            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                        'time': selectedTime!.format(context),
                        'duration':
                            '${sessionDuration.toStringAsFixed(1)} hours',
                        'link': linkController.text,
                        'password': passwordController.text,
                        'status': 'scheduled',
                        'attendees': 0,
                      };

                      setState(() {
                        _sessions.add(newSession);
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session scheduled successfully!'),
                          backgroundColor: Color(0xFF7A54FF),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A54FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  label: const Text(
                    'Schedule',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editSession(Map<String, dynamic> session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(text: session['title']);
    final descriptionController = TextEditingController(
      text: session['description'],
    );
    final linkController = TextEditingController(text: session['link']);
    final passwordController = TextEditingController(text: session['password']);
    String selectedPlatform = session['platform'] ?? 'Zoom';

    // Parse existing date and time
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    double sessionDuration = 1.0;

    try {
      if (session['date'] != null) {
        final dateParts = session['date'].split('-');
        if (dateParts.length == 3) {
          selectedDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
        }
      }

      if (session['time'] != null) {
        final timeString = session['time'] as String;
        final timeParts = timeString
            .replaceAll(RegExp(r'[^\d:]'), '')
            .split(':');
        if (timeParts.length >= 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          if (timeString.toLowerCase().contains('pm') && hour != 12) hour += 12;
          if (timeString.toLowerCase().contains('am') && hour == 12) hour = 0;
          selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }

      if (session['duration'] != null) {
        final durationString = session['duration'] as String;
        final match = RegExp(r'(\d+\.?\d*)').firstMatch(durationString);
        if (match != null) {
          sessionDuration = double.parse(match.group(1)!);
        }
      }
    } catch (e) {
      // Use default values if parsing fails
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              title: Text(
                'Edit Session',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Session Title *',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.title,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Platform Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedPlatform,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Platform *',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.video_call,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      items: ['Zoom', 'Google Meet', 'Teams'].map((
                        String platform,
                      ) {
                        return DropdownMenuItem<String>(
                          value: platform,
                          child: Text(platform, style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPlatform = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme
                                    .copyWith(primary: const Color(0xFF7A54FF)),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: const Color(0xFF7A54FF),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate != null
                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                  : 'Select Date *',
                              style: TextStyle(
                                color: selectedDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time Picker
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme
                                    .copyWith(primary: const Color(0xFF7A54FF)),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: const Color(0xFF7A54FF),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime != null
                                  ? selectedTime!.format(context)
                                  : 'Select Time *',
                              style: TextStyle(
                                color: selectedTime != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Duration Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration: ${sessionDuration.toStringAsFixed(1)} hours',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[400]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Icon(
                                  Icons.schedule,
                                  size: 20,
                                  color: const Color(0xFF7A54FF),
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: sessionDuration,
                                  min: 0.5,
                                  max: 4.0,
                                  divisions: 7,
                                  activeColor: const Color(0xFF7A54FF),
                                  inactiveColor: const Color(
                                    0xFF7A54FF,
                                  ).withOpacity(0.3),
                                  onChanged: (double value) {
                                    setState(() {
                                      sessionDuration = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Session Link
                    TextField(
                      controller: linkController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Session Link *',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.link,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextField(
                      controller: passwordController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password (optional)',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 20,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null &&
                        linkController.text.isNotEmpty) {
                      final sessionIndex = _sessions.indexWhere(
                        (s) => s['id'] == session['id'],
                      );
                      if (sessionIndex != -1) {
                        setState(() {
                          _sessions[sessionIndex] = {
                            ..._sessions[sessionIndex],
                            'title': titleController.text,
                            'description': descriptionController.text,
                            'platform': selectedPlatform,
                            'date':
                                '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                            'time': selectedTime!.format(context),
                            'duration':
                                '${sessionDuration.toStringAsFixed(1)} hours',
                            'link': linkController.text,
                            'password': passwordController.text,
                          };
                        });
                      }

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session updated successfully!'),
                          backgroundColor: Color(0xFF7A54FF),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A54FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  label: const Text(
                    'Update',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startSession(Map<String, dynamic> session) async {
    final link = session['link'] as String;

    try {
      // Parse the URL
      final uri = Uri.parse(link);

      // Show starting message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ${session['platform']} session...'),
            backgroundColor: const Color(0xFF7A54FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Launch the URL in browser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // This will open in browser/app
      );

      if (!launched) {
        // Fallback: copy link to clipboard
        _copyToClipboard(link, 'Session link');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open browser. Link copied to clipboard.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Error handling: copy link to clipboard as fallback
      _copyToClipboard(link, 'Session link');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening browser. Link copied to clipboard.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _viewSessionReport(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Session Report',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildReportRow('Date', session['date']),
              _buildReportRow('Duration', session['duration']),
              _buildReportRow('Platform', session['platform']),
              _buildReportRow('Attendees', '${session['attendees']} students'),
              const SizedBox(height: 8),
              Text(
                'Session completed successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

  Widget _buildReportRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}
