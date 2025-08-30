import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../providers/online_session_provider.dart';
import '../../../../../models/course_session.dart';

class OnlineSessionTab extends StatefulWidget {
  final Map<String, dynamic> course;

  const OnlineSessionTab({Key? key, required this.course}) : super(key: key);

  @override
  State<OnlineSessionTab> createState() => _OnlineSessionTabState();
}

class _OnlineSessionTabState extends State<OnlineSessionTab> {
  final Map<String, bool> _expandedDescriptions = {};

  @override
  void initState() {
    super.initState();
    // Load sessions when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  Future<void> _loadSessions() async {
    final sessionProvider = Provider.of<OnlineSessionProvider>(
      context,
      listen: false,
    );
    final courseId = widget.course['id']?.toString() ?? '';
    if (courseId.isNotEmpty) {
      await sessionProvider.loadSessions(courseId);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTime(String timeString) {
    try {
      // Parse the time string and format it nicely
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        final time = TimeOfDay(hour: hour, minute: minute);
        final now = DateTime.now();
        final dateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        return DateFormat('h:mm a').format(dateTime);
      }
    } catch (e) {
      // Return original string if parsing fails
    }
    return timeString;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    return Consumer<OnlineSessionProvider>(
      builder: (context, sessionProvider, child) {
        final sessions = sessionProvider.sessions;
        final totalSessions = sessions.length;
        final completedSessions = sessions.where((s) => s.isCompleted).length;
        final upcomingSessions = sessions.where((s) => s.isUpcoming).toList();

        // Sort upcoming sessions by date to show closest first
        if (upcomingSessions.isNotEmpty) {
          upcomingSessions.sort(
            (a, b) => a.sessionDate.compareTo(b.sessionDate),
          );
        }

        // Show loading state
        if (sessionProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A54FF)),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                            'Live Sessions',
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
                      'Join interactive sessions',
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
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            '$totalSessions',
                            Icons.event,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Done',
                            '$completedSessions',
                            Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 8),
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

                    // Next Session Date
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
                                        _formatDate(
                                          upcomingSessions.first.sessionDate,
                                        ),
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
                                        _formatTime(
                                          upcomingSessions.first.sessionTime,
                                        ),
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
                'Scheduled Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Show empty state or sessions list
              if (sessions.isEmpty)
                _buildEmptyState(isDark, primaryColor)
              else
                ...sessions
                    .map(
                      (session) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black26
                                  : Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildSessionCard(
                          session,
                          isDark,
                          primaryColor,
                          textColor,
                          subTextColor,
                        ),
                      ),
                    )
                    .toList(),
            ],
          ),
        );
      },
    );
  }

  // Build stat card helper
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Build empty state when no sessions are available
  Widget _buildEmptyState(bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
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
        children: [
          Icon(
            Icons.video_call_outlined,
            size: 48,
            color: primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions scheduled yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for upcoming sessions',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build individual session card
  Widget _buildSessionCard(
    CourseSession session,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getSessionStatusColor(session.status).withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getSessionStatusColor(session.status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusDisplayText(session.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _getSessionPlatformIcon(session.sessionPlatform),
                color: _getSessionStatusColor(session.status),
                size: 16,
              ),
              const SizedBox(width: 3),
              Text(
                session.displayPlatform,
                style: TextStyle(
                  color: _getSessionStatusColor(session.status),
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
                session.sessionName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              if (session.sessionDescription.isNotEmpty)
                _buildSessionDescription(
                  session.sessionDescription,
                  session.id,
                  subTextColor,
                ),

              const SizedBox(height: 12),

              // Session Info Grid
              Row(
                children: [
                  Expanded(
                    child: _buildSessionInfoRow(
                      Icons.calendar_today,
                      _formatDate(session.sessionDate),
                      textColor,
                    ),
                  ),
                  Expanded(
                    child: _buildSessionInfoRow(
                      Icons.access_time,
                      _formatTime(session.sessionTime),
                      textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildSessionInfoRow(
                Icons.schedule,
                'Duration: ${session.sessionDuration}',
                textColor,
              ),

              // Session Link and Password (for upcoming and completed)
              if (session.isUpcoming || session.isCompleted) ...[
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
                if (session.sessionLink.isNotEmpty)
                  _buildSessionCopyableField(
                    'Session Link',
                    session.sessionLink,
                    Icons.link,
                    primaryColor,
                  ),

                const SizedBox(height: 6),

                // Session Password
                if (session.sessionPassword != null &&
                    session.sessionPassword!.isNotEmpty)
                  _buildSessionCopyableField(
                    'Password',
                    session.sessionPassword!,
                    Icons.lock,
                    primaryColor,
                  ),
              ],

              const SizedBox(height: 12),

              // Action Button
              if (session.isUpcoming) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _joinSessionFromModel(session);
                    },
                    icon: Icon(
                      _getSessionPlatformIcon(session.sessionPlatform),
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
              ] else if (session.isCompleted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
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
    );
  }

  // Method to expand or collapse session description
  Widget _buildSessionDescription(
    String description,
    String sessionId,
    Color subTextColor,
  ) {
    final isExpanded = _expandedDescriptions[sessionId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            description,
            style: TextStyle(fontSize: 12, color: subTextColor, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            description,
            style: TextStyle(fontSize: 12, color: subTextColor, height: 1.3),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (description.length > 80) // Only show expand button for long text
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedDescriptions[sessionId] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? 'See Less' : 'See More',
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

  // Copyable field widget with clipboard functionality for sessions
  Widget _buildSessionCopyableField(
    String label,
    String value,
    IconData icon,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryColor.withOpacity(0.8),
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.copy, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Build info row helper for sessions
  Widget _buildSessionInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: textColor.withOpacity(0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Get status color based on session status
  Color _getSessionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
      case 'upcoming':
        return const Color(0xFF7A54FF);
      case 'live':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get display text for status
  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'COMPLETED';
      case 'scheduled':
        return 'SCHEDULED';
      case 'upcoming':
        return 'UPCOMING';
      case 'live':
        return 'LIVE';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  // Get platform icon based on platform name
  IconData _getSessionPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'zoom':
        return Icons.videocam;
      case 'meet':
      case 'google meet':
        return Icons.video_call;
      case 'teams':
      case 'microsoft teams':
        return Icons.groups;
      case 'webex':
        return Icons.web;
      default:
        return Icons.videocam;
    }
  }

  // Handle session join action for CourseSession model
  void _joinSessionFromModel(CourseSession session) async {
    final sessionLink = session.sessionLink;

    if (sessionLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session link not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (await canLaunchUrl(Uri.parse(sessionLink))) {
        await launchUrl(
          Uri.parse(sessionLink),
          mode: LaunchMode.externalApplication,
        );

        // Show session password if available
        if (session.sessionPassword != null &&
            session.sessionPassword!.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password: ${session.sessionPassword}'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: session.sessionPassword!),
                  );
                },
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open session link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening session'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
