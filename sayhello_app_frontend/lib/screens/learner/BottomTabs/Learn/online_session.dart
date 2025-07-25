import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class OnlineSessionTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const OnlineSessionTab({super.key, required this.course});

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

    // Dynamic session data with enrollment status and scheduling
    final sessions = [
      {
        'id': 'session_1',
        'title': 'Introduction to Course Fundamentals',
        'instructor': course['instructor'] ?? 'John Doe',
        'platform': 'Zoom',
        'date': '2025-07-25',
        'time': '6:00 PM',
        'duration': '1.5 hours',
        'status': 'upcoming', // upcoming, live, completed, cancelled
        'attendees': 24,
        'maxAttendees': 30,
        'description':
            'Learn the foundational concepts and meet your fellow learners.',
        'link': 'https://zoom.us/j/sample-session-1',
        'thumbnail': null,
        'topics': ['Course Overview', 'Learning Objectives', 'Q&A Session'],
      },
      {
        'id': 'session_2',
        'title': 'Advanced Techniques & Practice',
        'instructor': course['instructor'] ?? 'John Doe',
        'platform': 'Google Meet',
        'date': '2025-07-28',
        'time': '4:30 PM',
        'duration': '2 hours',
        'status': 'upcoming',
        'attendees': 18,
        'maxAttendees': 25,
        'description':
            'Dive deeper into advanced concepts with hands-on practice.',
        'link': 'https://meet.google.com/sample-session-2',
        'thumbnail': null,
        'topics': [
          'Advanced Concepts',
          'Interactive Exercises',
          'Group Activities',
        ],
      },
      {
        'id': 'session_3',
        'title': 'Review & Assessment Session',
        'instructor': course['instructor'] ?? 'John Doe',
        'platform': 'Zoom',
        'date': '2025-07-20',
        'time': '7:00 PM',
        'duration': '1 hour',
        'status': 'completed',
        'attendees': 28,
        'maxAttendees': 30,
        'description':
            'Review key concepts and complete your progress assessment.',
        'link': 'https://zoom.us/j/sample-session-3',
        'thumbnail': null,
        'topics': ['Concept Review', 'Skills Assessment', 'Feedback Session'],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // Reduced padding to prevent overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16), // Reduced padding
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
            ), // Prevent overflow
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.indigo.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.video_call,
                      color: Colors.white,
                      size: 24,
                    ), // Reduced size
                    SizedBox(width: 8),
                    Expanded(
                      // Prevent overflow
                      child: Text(
                        AppLocalizations.of(context)!.liveSessions,
                        style: TextStyle(
                          fontSize: 20, // Reduced font size
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
                    fontSize: 14,
                    color: Colors.white70,
                  ), // Reduced font size
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Use Wrap instead of Row to prevent overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatCard(
                      AppLocalizations.of(context)!.totalSessions,
                      '${sessions.length}',
                      Icons.event,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      AppLocalizations.of(context)!.attended,
                      '${sessions.where((s) => s['status'] == 'completed').length}',
                      Icons.check_circle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sessions List
          Text(
            AppLocalizations.of(context)!.scheduledSessions,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          ...sessions
              .map(
                (session) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            session['status'],
                          ).withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(session['status']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                session['status'].toString().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _getPlatformIcon(session['platform']),
                              color: _getStatusColor(session['status']),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session['platform'] ?? '',
                              style: TextStyle(
                                color: _getStatusColor(session['status']),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Session Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session['title'] ?? 'Untitled Session',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              session['description'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: subTextColor,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),

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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.schedule,
                                    session['duration'] ?? '',
                                    textColor,
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.people,
                                    '${session['attendees']}/${session['maxAttendees']}',
                                    textColor,
                                  ),
                                ),
                              ],
                            ),

                            if (session['topics'] != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.topicsCovered,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: (session['topics'] as List)
                                    .map(
                                      (topic) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          topic,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.purple,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getStatusColor(
                                    session['status'],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  if (session['status'] == 'upcoming') {
                                    _showSessionReminder(context, session);
                                  } else if (session['status'] == 'live') {
                                    _joinSession(context, session);
                                  } else {
                                    _viewSessionRecording(context, session);
                                  }
                                },
                                child: Text(
                                  _getButtonText(session['status'], context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.purple),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, color: textColor)),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'live':
        return Colors.purple.shade600;
      case 'upcoming':
        return Colors.purple.shade400;
      case 'completed':
        return Colors.purple.shade300;
      case 'cancelled':
        return Colors.purple.shade200;
      default:
        return Colors.purple;
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

  String _getButtonText(String? status, BuildContext context) {
    switch (status) {
      case 'live':
        return AppLocalizations.of(context)!.joinSession;
      case 'upcoming':
        return AppLocalizations.of(context)!.setReminder;
      case 'completed':
        return AppLocalizations.of(context)!.viewRecording;
      case 'cancelled':
        return AppLocalizations.of(context)!.sessionCancelled;
      default:
        return AppLocalizations.of(context)!.viewDetails;
    }
  }

  void _showSessionReminder(
    BuildContext context,
    Map<String, dynamic> session,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.reminderSetFor} ${session['title']}',
        ),
        backgroundColor: Colors.purple.shade400,
      ),
    );
  }

  void _joinSession(BuildContext context, Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.joining} ${session['title']}...',
        ),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }

  void _viewSessionRecording(
    BuildContext context,
    Map<String, dynamic> session,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.loadingRecordingFor} ${session['title']}',
        ),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
