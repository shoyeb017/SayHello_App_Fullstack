import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';

class OnlineSessionTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const OnlineSessionTab({super.key, required this.course});

  @override
  State<OnlineSessionTab> createState() => _OnlineSessionTabState();
}

class _OnlineSessionTabState extends State<OnlineSessionTab> {
  final Map<String, bool> _expandedDescriptions = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Updated theme colors
    final primaryColor = Color(0xFF7A54FF);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    // Dynamic session data with enrollment status and scheduling
    final sessions = [
      {
        'id': 'session_1',
        'title': 'Introduction to Course Fundamentals',
        'instructor': widget.course['instructor'] ?? 'John Doe',
        'platform': 'Zoom',
        'date': '2025-08-15',
        'time': '6:00 PM',
        'duration': '1.5 hours',
        'status': 'upcoming', // upcoming, live, completed, cancelled
        'description':
            'Learn the foundational concepts and meet your fellow learners.',
        'link': 'https://zoom.us/j/1234567890?pwd=abcd1234',
        'password': 'Learn123',
        'thumbnail': null,
      },
      {
        'id': 'session_2',
        'title': 'Advanced Techniques & Practice',
        'instructor': widget.course['instructor'] ?? 'John Doe',
        'platform': 'Google Meet',
        'date': '2025-08-20',
        'time': '4:30 PM',
        'duration': '2 hours',
        'status': 'upcoming',
        'description':
            'Dive deeper into advanced concepts with hands-on practice.',
        'link': 'https://meet.google.com/abc-defg-hij',
        'password': 'Advanced456',
        'thumbnail': null,
      },
      {
        'id': 'session_3',
        'title': 'Review & Assessment Session',
        'instructor': widget.course['instructor'] ?? 'John Doe',
        'platform': 'Zoom',
        'date': '2025-07-20',
        'time': '7:00 PM',
        'duration': '1 hour',
        'status': 'completed',
        'description':
            'Review key concepts and complete your progress assessment.',
        'link': 'https://zoom.us/j/0987654321?pwd=xyz789',
        'password': 'Review789',
        'thumbnail': null,
      },
    ];

    // Get upcoming sessions and find closest date
    final upcomingSessions = sessions
        .where((s) => s['status'] == 'upcoming')
        .toList();

    // Sort upcoming sessions by date to show closest first
    if (upcomingSessions.isNotEmpty) {
      upcomingSessions.sort((a, b) => a['date'].compareTo(b['date']));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // Reduced padding to prevent overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.8), primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.video_call, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.liveSessions,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.joinInteractiveSessions,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Statistics Row
                Row(
                  children: [
                    // Total Sessions
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        '${sessions.length}',
                        Icons.event,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Completed Sessions
                    Expanded(
                      child: _buildStatCard(
                        'Done',
                        '${sessions.where((s) => s['status'] == 'completed').length}',
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Upcoming Sessions
                    Expanded(
                      child: _buildStatCard(
                        'Next',
                        '${upcomingSessions.length}',
                        Icons.schedule,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Next Session Date - Modern Design
                if (upcomingSessions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Session',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    upcomingSessions.first['date'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    upcomingSessions.first['time'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sessions List
          Text(
            AppLocalizations.of(context)!.scheduledSessions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          ...sessions
              .map(
                (session) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            session['status'],
                          ).withOpacity(0.1),
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
                                color: _getStatusColor(session['status']),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                session['status'].toString().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _getPlatformIcon(session['platform']),
                              color: _getStatusColor(session['status']),
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              session['platform'] ?? '',
                              style: TextStyle(
                                color: _getStatusColor(session['status']),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildExpandableDescription(
                              session['description'] ?? '',
                              session['id'],
                              subTextColor,
                            ),

                            const SizedBox(height: 12),

                            // Session Info Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.calendar_today,
                                    session['date'] ?? '',
                                    textColor,
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.access_time,
                                    session['time'] ?? '',
                                    textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildInfoRow(
                              Icons.schedule,
                              'Duration: ${session['duration'] ?? ''}',
                              textColor,
                            ),

                            // Session Link and Password (for upcoming and completed)
                            if (session['status'] == 'upcoming' ||
                                session['status'] == 'completed') ...[
                              const SizedBox(height: 12),
                              Text(
                                'Session Details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Session Link
                              _buildCopyableField(
                                'Session Link',
                                session['link'] ?? '',
                                Icons.link,
                                primaryColor,
                                context,
                              ),

                              const SizedBox(height: 6),

                              // Session Password
                              _buildCopyableField(
                                'Password',
                                session['password'] ?? '',
                                Icons.lock,
                                primaryColor,
                                context,
                              ),
                            ],

                            const SizedBox(height: 12),

                            // Action Button
                            if (session['status'] == 'upcoming') ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _joinSession(context, session);
                                  },
                                  icon: Icon(
                                    _getPlatformIcon(session['platform']),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Join Now',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (session['status'] == 'completed') ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Session Completed',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildExpandableDescription(
    String description,
    String sessionId,
    Color subTextColor,
  ) {
    final isExpanded = _expandedDescriptions[sessionId] ?? false;
    final maxLines = isExpanded ? null : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: TextStyle(fontSize: 12, color: subTextColor, height: 1.3),
          maxLines: maxLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (description.length > 80) // Show toggle only for longer descriptions
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedDescriptions[sessionId] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? 'See less' : 'See more',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7A54FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      height: 63, // Increased height for better readability
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9, // Increased from 7 to 9 for better readability
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(
    String label,
    String value,
    IconData icon,
    Color primaryColor,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value.length > 20 ? '${value.substring(0, 20)}...' : value,
              style: TextStyle(
                fontSize: 11,
                color: primaryColor.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              _copyToClipboard(context, value, label);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.copy, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Color(0xFF7A54FF)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    final primaryColor = Color(0xFF7A54FF);
    switch (status) {
      case 'live':
        return primaryColor;
      case 'upcoming':
        return primaryColor.withOpacity(0.8);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return primaryColor;
    }
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

  void _copyToClipboard(BuildContext context, String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied to clipboard'),
            backgroundColor: Color(0xFF7A54FF),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy $label'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _joinSession(BuildContext context, Map<String, dynamic> session) async {
    final link = session['link'] as String;

    try {
      // Parse the URL
      final uri = Uri.parse(link);

      // Show joining message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Opening ${session['platform']} session in browser...',
            ),
            backgroundColor: Color(0xFF7A54FF),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Launch the URL in browser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // This will open in browser
      );

      if (!launched) {
        // Fallback: copy link to clipboard
        _copyToClipboard(context, link, 'Session link');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
      _copyToClipboard(context, link, 'Session link');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening browser. Link copied to clipboard.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
