import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock notification data with only session alerts and feedback
  final List<Map<String, dynamic>> notifications = [
    {
      'notification_type': 'session_alert',
      'is_read': false,
      'created_at': DateTime.now().subtract(Duration(minutes: 30)),
      'course_name': 'Japanese for Beginners',
      'instructor_name': 'Hiro Tanaka',
      'session_time': '3:00 PM',
      'session_date': 'August 10, 2025',
    },
    {
      'notification_type': 'feedback',
      'is_read': false,
      'created_at': DateTime.now().subtract(Duration(hours: 2)),
      'course_name': 'Conversational Spanish',
      'instructor_name': 'Maria Gomez',
      'rating': 4.8,
    },
    {
      'notification_type': 'session_alert',
      'is_read': true,
      'created_at': DateTime.now().subtract(Duration(hours: 5)),
      'course_name': 'German Advanced Grammar',
      'instructor_name': 'Klaus Schmidt',
      'session_time': '10:00 AM',
      'session_date': 'August 12, 2025',
    },
    {
      'notification_type': 'feedback',
      'is_read': true,
      'created_at': DateTime.now().subtract(Duration(days: 1)),
      'course_name': 'French Grammar Essentials',
      'instructor_name': 'Jean Dupont',
      'rating': 4.5,
    },
    {
      'notification_type': 'session_alert',
      'is_read': true,
      'created_at': DateTime.now().subtract(Duration(days: 2)),
      'course_name': 'Italian Basics',
      'instructor_name': 'Marco Rossi',
      'session_time': '2:30 PM',
      'session_date': 'August 15, 2025',
    },
  ];

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return AppLocalizations.of(
        context,
      )!.minutesAgo(difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(
        context,
      )!.hoursAgo(difference.inHours.toString());
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(
        context,
      )!.daysAgo(difference.inDays.toString());
    } else {
      return AppLocalizations.of(
        context,
      )!.weeksAgo((difference.inDays ~/ 7).toString());
    }
  }

  String _getNotificationTitle(Map<String, dynamic> notification) {
    final isSessionAlert = notification['notification_type'] == 'session_alert';
    return isSessionAlert
        ? AppLocalizations.of(context)!.newSessionAvailable
        : AppLocalizations.of(context)!.courseFeedbackReceived;
  }

  String _getNotificationContent(Map<String, dynamic> notification) {
    final isSessionAlert = notification['notification_type'] == 'session_alert';

    if (isSessionAlert) {
      return AppLocalizations.of(context)!.sessionScheduled(
        notification['course_name'],
        notification['instructor_name'],
        notification['session_date'],
        notification['session_time'],
      );
    } else {
      return AppLocalizations.of(context)!.feedbackReceived(
        notification['rating'].toString(),
        notification['course_name'],
        notification['instructor_name'],
      );
    }
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['is_read'] = true;
    });
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    int index,
    bool isDark,
  ) {
    final isUnread = !notification['is_read'];
    final isSessionAlert = notification['notification_type'] == 'session_alert';

    return InkWell(
      onTap: () => _markAsRead(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark
                    ? Color(0xFF7A54FF).withOpacity(0.1)
                    : Color(0xFF7A54FF).withOpacity(0.05))
              : (isDark ? Colors.grey[850] : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: Color(0xFF7A54FF).withOpacity(0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with colored background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF7A54FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSessionAlert ? Icons.schedule : Icons.star_rate,
                color: Color(0xFF7A54FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getNotificationTitle(notification),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFF7A54FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    _getNotificationContent(notification),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _getTimeAgo(notification['created_at']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = notifications.where((n) => !n['is_read']).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => SettingsProvider.showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with unread count
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF7A54FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF7A54FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFF7A54FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.youHaveNewNotifications(
                        unreadCount.toString(),
                        unreadCount != 1 ? 's' : '',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A54FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        notifications[index],
                        index,
                        isDark,
                      );
                    },
                  ),
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
            Icons.notifications_none,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotificationsYet,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.allCaughtUp,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
