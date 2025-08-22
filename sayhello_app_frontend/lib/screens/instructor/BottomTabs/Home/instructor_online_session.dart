import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/online_session_provider.dart';
import '../../../../../models/course_session.dart';

class InstructorOnlineSessionTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorOnlineSessionTab({super.key, required this.course});

  @override
  State<InstructorOnlineSessionTab> createState() =>
      _InstructorOnlineSessionTabState();
}

class _InstructorOnlineSessionTabState
    extends State<InstructorOnlineSessionTab> {
  // Track expanded state for each session
  Map<String, bool> _expandedSessions = {};

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  /// Load sessions for this course
  void _loadSessions() {
    if (!mounted) return;

    final sessionProvider = context.read<OnlineSessionProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId != null) {
      sessionProvider.loadSessions(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Consumer<OnlineSessionProvider>(
      builder: (context, sessionProvider, child) {
        final sessions = sessionProvider.sessions;

        // Get session statistics
        final totalSessions = sessions.length;
        final completedSessions = sessions.where((s) => s.isCompleted).length;
        final upcomingSessions = sessions.where((s) => s.isUpcoming).length;

        return Column(
          children: [
            // Add Session Button - More Visible
            Container(
              margin: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddSessionDialog(localizations),
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    localizations.scheduleNewSession,
                    style: const TextStyle(
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
                      Icon(
                        Icons.video_camera_front,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.sessionOverview,
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
                        localizations.total,
                        totalSessions.toString(),
                        Icons.event,
                        primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _buildQuickStat(
                        localizations.done,
                        completedSessions.toString(),
                        Icons.check_circle,
                        primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _buildQuickStat(
                        localizations.next,
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
              child: sessionProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sessions.isEmpty
                  ? _buildEmptyState(isDark, primaryColor, localizations)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _getSortedSessions(sessions).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final sortedSessions = _getSortedSessions(sessions);
                        return _buildSessionCard(
                          sortedSessions[index],
                          isDark,
                          primaryColor,
                          textColor,
                          subTextColor,
                          localizations,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // Method to sort sessions by date and time (newest first)
  List<CourseSession> _getSortedSessions(List<CourseSession> sessions) {
    List<CourseSession> sortedSessions = List.from(sessions);

    sortedSessions.sort((a, b) {
      try {
        // Compare session dates
        int dateComparison = b.sessionDate.compareTo(a.sessionDate);

        // If dates are the same, compare by time
        if (dateComparison == 0) {
          // Parse times and compare
          _TimeOfDay timeA = _parseTime(a.sessionTime);
          _TimeOfDay timeB = _parseTime(b.sessionTime);

          // Convert to minutes for easier comparison
          int minutesA = timeA.hour * 60 + timeA.minute;
          int minutesB = timeB.hour * 60 + timeB.minute;

          return minutesB.compareTo(minutesA); // Newer time first
        }

        return dateComparison; // Newer date first
      } catch (e) {
        // If parsing fails, maintain original order
        return 0;
      }
    });

    return sortedSessions;
  }

  // Helper method to parse time strings
  _TimeOfDay _parseTime(String timeString) {
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

        return _TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return default time if parsing fails
    }

    return const _TimeOfDay(hour: 0, minute: 0);
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
    CourseSession session,
    bool isDark,
    Color primaryColor,
    Color? textColor,
    Color? subTextColor,
    AppLocalizations localizations,
  ) {
    final status = session.status;
    final statusColor = _getStatusColor(status);
    final sessionId = session.id;

    final title = session.sessionName;
    final description = session.sessionDescription;
    final shouldShowToggle = title.length > 30 || description.length > 50;
    final isExpanded = _expandedSessions[sessionId] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row - Status, Title, Platform, Actions
          Row(
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
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
              const SizedBox(width: 8),

              // Title
              Expanded(
                child: isExpanded || !shouldShowToggle
                    ? Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: textColor,
                        ),
                      )
                    : Text(
                        title.length > 30
                            ? '${title.substring(0, 30)}...'
                            : title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),

              // Platform Icon
              Icon(
                _getPlatformIcon(session.sessionPlatform),
                color: statusColor,
                size: 16,
              ),
              const SizedBox(width: 4),

              // Delete Button
              InkWell(
                onTap: () => _deleteSession(session.id, localizations),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description with More/Less
          if (description.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isExpanded || !shouldShowToggle
                    ? Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          height: 1.3,
                        ),
                      )
                    : Text(
                        description.length > 50
                            ? '${description.substring(0, 50)}...'
                            : description,
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                if (shouldShowToggle) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedSessions[sessionId] = !isExpanded;
                      });
                    },
                    child: Text(
                      isExpanded
                          ? localizations.showLess
                          : localizations.showMore,
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Compact Info Row (removed attendees)
          Row(
            children: [
              // Date & Time
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${session.formattedDate} • ${session.sessionTime}',
                        style: TextStyle(fontSize: 11, color: primaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Duration
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty, size: 12, color: primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.sessionDuration,
                        style: TextStyle(fontSize: 11, color: primaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Individual Copy Buttons Row
          Row(
            children: [
              if (session.sessionLink.isNotEmpty) ...[
                Expanded(
                  child: InkWell(
                    onTap: () => _copyToClipboard(
                      session.sessionLink,
                      localizations.copyLink,
                      localizations,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link, color: primaryColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            localizations.copyLink,
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (session.sessionLink.isNotEmpty &&
                  session.sessionPassword != null &&
                  session.sessionPassword!.isNotEmpty)
                const SizedBox(width: 8),
              if (session.sessionPassword != null &&
                  session.sessionPassword!.isNotEmpty) ...[
                Expanded(
                  child: InkWell(
                    onTap: () => _copyToClipboard(
                      session.sessionPassword!,
                      localizations.copyPassword,
                      localizations,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: primaryColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            localizations.copyPassword,
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Compact Action Buttons (removed view report)
          if (status == 'scheduled') ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => _editSession(session, localizations),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        localizations.edit,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _startSession(session, localizations),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        localizations.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (session.isUpcoming) ...[
            // For upcoming sessions that aren't exactly 'scheduled'
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => _editSession(session, localizations),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        localizations.edit,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _startSession(session, localizations),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        localizations.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color primaryColor,
    AppLocalizations localizations,
  ) {
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
            localizations.noSessionsScheduled,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.createYourFirstSession,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddSessionDialog(localizations),
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: Text(
              localizations.scheduleSession,
              style: const TextStyle(color: Colors.white, fontSize: 12),
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

  void _copyToClipboard(
    String text,
    String label,
    AppLocalizations localizations,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.linkCopiedToClipboard(label)),
            backgroundColor: const Color(0xFF7A54FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.failedToCopy(label)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteSession(String sessionId, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            localizations.deleteSession,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            localizations.deleteSessionConfirmation,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                final sessionProvider = context.read<OnlineSessionProvider>();
                final courseId = widget.course['id']?.toString();

                if (courseId != null) {
                  final success = await sessionProvider.deleteSession(
                    sessionId,
                    courseId,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? localizations.sessionDeletedSuccessfully
                              : sessionProvider.error?.isNotEmpty == true
                              ? sessionProvider.error!
                              : 'Failed to delete session',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                localizations.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddSessionDialog(AppLocalizations localizations) {
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
                localizations.scheduleNewSession,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height:
                    MediaQuery.of(context).size.height * 0.6, // Limit height
                child: SingleChildScrollView(
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
                            child: Text(
                              platform,
                              style: TextStyle(fontSize: 14),
                            ),
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
                                      .copyWith(
                                        primary: const Color(0xFF7A54FF),
                                      ),
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
                                      .copyWith(
                                        primary: const Color(0xFF7A54FF),
                                      ),
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
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
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
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null &&
                        linkController.text.isNotEmpty) {
                      final sessionProvider = context
                          .read<OnlineSessionProvider>();
                      final courseId = widget.course['id']?.toString();

                      if (courseId != null) {
                        final success = await sessionProvider.createSession(
                          courseId: courseId,
                          title: titleController.text,
                          description: descriptionController.text,
                          platform: selectedPlatform,
                          date: selectedDate!,
                          time: selectedTime!.format(context),
                          duration:
                              '${sessionDuration.toStringAsFixed(1)} hours',
                          link: linkController.text,
                          password: passwordController.text.isNotEmpty
                              ? passwordController.text
                              : null,
                        );

                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? localizations.sessionScheduledSuccessfully
                                    : 'Failed to create session',
                              ),
                              backgroundColor: success
                                  ? const Color(0xFF7A54FF)
                                  : Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.fillAllRequiredFields),
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
                  label: Text(
                    localizations.scheduleSession,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editSession(CourseSession session, AppLocalizations localizations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(text: session.sessionName);
    final descriptionController = TextEditingController(
      text: session.sessionDescription,
    );
    final linkController = TextEditingController(text: session.sessionLink);
    final passwordController = TextEditingController(
      text: session.sessionPassword ?? '',
    );
    String selectedPlatform = session.displayPlatform;

    // Parse existing date and time
    DateTime? selectedDate = session.sessionDate;
    TimeOfDay? selectedTime;
    double sessionDuration = 1.0;

    try {
      // Parse time from session
      final timeString = session.sessionTime;
      final timeParts = timeString.replaceAll(RegExp(r'[^\d:]'), '').split(':');
      if (timeParts.length >= 2) {
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (timeString.toLowerCase().contains('pm') && hour != 12) hour += 12;
        if (timeString.toLowerCase().contains('am') && hour == 12) hour = 0;
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      }

      // Parse duration from session
      final durationString = session.sessionDuration;
      final match = RegExp(r'(\d+\.?\d*)').firstMatch(durationString);
      if (match != null) {
        sessionDuration = double.parse(match.group(1)!);
      }
    } catch (e) {
      // Use default values if parsing fails
      selectedTime = TimeOfDay.now();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              title: Text(
                localizations.editSession,
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
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null &&
                        linkController.text.isNotEmpty) {
                      final sessionProvider = context
                          .read<OnlineSessionProvider>();
                      final courseId = widget.course['id']?.toString();

                      if (courseId != null) {
                        final success = await sessionProvider.updateSession(
                          sessionId: session.id,
                          courseId: courseId,
                          title: titleController.text,
                          description: descriptionController.text,
                          platform: selectedPlatform,
                          date: selectedDate!,
                          time: selectedTime!.format(context),
                          duration:
                              '${sessionDuration.toStringAsFixed(1)} hours',
                          link: linkController.text,
                          password: passwordController.text.isNotEmpty
                              ? passwordController.text
                              : null,
                        );

                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? localizations.sessionUpdatedSuccessfully
                                    : 'Failed to update session',
                              ),
                              backgroundColor: success
                                  ? const Color(0xFF7A54FF)
                                  : Colors.red,
                            ),
                          );
                        }
                      }
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
                  label: Text(
                    localizations.update,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startSession(
    CourseSession session,
    AppLocalizations localizations,
  ) async {
    final link = session.sessionLink;

    try {
      // Debug: Log the original link
      print('Original session link: $link');

      // Show starting message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ${session.displayPlatform} session...'),
            backgroundColor: const Color(0xFF7A54FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Validate and parse the URL
      Uri uri;
      try {
        // Clean the link first (remove extra spaces, etc.)
        String cleanLink = link.trim();

        // Check if the link already has a protocol
        if (!cleanLink.startsWith('http://') &&
            !cleanLink.startsWith('https://')) {
          // Add https:// if no protocol is specified
          uri = Uri.parse('https://$cleanLink');
          print('Added https:// protocol. New URL: ${uri.toString()}');
        } else {
          uri = Uri.parse(cleanLink);
          print('Using original URL: ${uri.toString()}');
        }

        // Validate that it's a proper URL
        if (!uri.hasScheme || uri.host.isEmpty) {
          throw Exception('Invalid URL structure');
        }
      } catch (e) {
        print('URL parsing error: $e');
        throw Exception('Invalid URL format: $link');
      }

      // Skip canLaunchUrl check as it seems to fail incorrectly on some devices
      // Instead, directly try launching with different modes

      bool launched = false;
      List<String> attemptLog = [];

      // Strategy 1: Try platform default first (best for web URLs)
      try {
        print('Attempting launch with platform default...');
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        attemptLog.add('Platform default: $launched');
        print('Platform default result: $launched');
      } catch (e) {
        attemptLog.add('Platform default failed: $e');
        print('Failed to launch with platform default: $e');
      }

      // Strategy 2: Try external application if first attempt failed
      if (!launched) {
        try {
          print('Attempting launch with external application...');
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          attemptLog.add('External app: $launched');
          print('External application result: $launched');
        } catch (e) {
          attemptLog.add('External app failed: $e');
          print('Failed to launch in external app: $e');
        }
      }

      // Strategy 3: Try external non-browser application
      if (!launched) {
        try {
          print('Attempting launch with external non-browser...');
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          attemptLog.add('External non-browser: $launched');
          print('External non-browser result: $launched');
        } catch (e) {
          attemptLog.add('External non-browser failed: $e');
          print('Failed to launch with external non-browser: $e');
        }
      }

      // Strategy 4: Try in-app web view as last resort
      if (!launched) {
        try {
          print('Attempting launch with in-app web view...');
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
          attemptLog.add('In-app web view: $launched');
          print('In-app web view result: $launched');
        } catch (e) {
          attemptLog.add('In-app web view failed: $e');
          print('Failed to launch in web view: $e');
        }
      }

      print('Launch attempt summary: ${attemptLog.join(', ')}');

      if (launched) {
        print('Successfully launched URL with one of the methods');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session started successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('All launch attempts failed - providing fallback');
        // Fallback: copy link to clipboard and show instructions
        _copyToClipboard(link, 'Session link', localizations);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unable to auto-launch session. Link copied to clipboard - please paste in your browser.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error starting session: $e');
      // Error handling: copy link to clipboard as fallback
      _copyToClipboard(link, 'Session link', localizations);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error opening session: ${e.toString()}. Link copied to clipboard.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

/// Helper class for time parsing
class _TimeOfDay {
  final int hour;
  final int minute;

  const _TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
