import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock notification data for language learning platform
  final List<Map<String, dynamic>> allNotifications = [
    {
      'id': 'notif_001',
      'type': 'course_reminder',
      'title': 'Japanese Lesson Reminder',
      'message':
          'Your next Japanese lesson starts in 30 minutes! Don\'t forget to review Hiragana characters.',
      'time': DateTime.now().subtract(Duration(minutes: 15)),
      'isRead': false,
      'icon': Icons.schedule,
      'color': Colors.blue,
      'courseTitle': 'Japanese for Beginners',
      'actionType': 'join_lesson',
    },
    {
      'id': 'notif_002',
      'type': 'achievement',
      'title': 'New Achievement Unlocked! 🎉',
      'message':
          'Congratulations! You\'ve completed 7 days in a row. Keep up the great work!',
      'time': DateTime.now().subtract(Duration(hours: 2)),
      'isRead': false,
      'icon': Icons.emoji_events,
      'color': Colors.amber,
      'actionType': 'view_achievement',
    },
    {
      'id': 'notif_003',
      'type': 'assignment',
      'title': 'Assignment Due Soon',
      'message':
          'Your Spanish conversation practice assignment is due tomorrow. Complete it now!',
      'time': DateTime.now().subtract(Duration(hours: 4)),
      'isRead': false,
      'icon': Icons.assignment,
      'color': Colors.orange,
      'courseTitle': 'Conversational Spanish',
      'actionType': 'complete_assignment',
    },
    {
      'id': 'notif_004',
      'type': 'progress',
      'title': 'Weekly Progress Report',
      'message':
          'You\'ve completed 85% of your weekly learning goals. Just 2 more lessons to go!',
      'time': DateTime.now().subtract(Duration(hours: 6)),
      'isRead': true,
      'icon': Icons.trending_up,
      'color': Colors.green,
      'actionType': 'view_progress',
    },
    {
      'id': 'notif_005',
      'type': 'social',
      'title': 'New Study Buddy Request',
      'message':
          'Maria from Spain wants to practice English with you. Accept her request?',
      'time': DateTime.now().subtract(Duration(hours: 8)),
      'isRead': true,
      'icon': Icons.people,
      'color': Colors.purple,
      'actionType': 'view_request',
    },
    {
      'id': 'notif_006',
      'type': 'course_update',
      'title': 'Course Content Updated',
      'message':
          'New vocabulary exercises have been added to your German Advanced Grammar course.',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'icon': Icons.update,
      'color': Colors.indigo,
      'courseTitle': 'German Advanced Grammar',
      'actionType': 'view_course',
    },
    {
      'id': 'notif_007',
      'type': 'quiz',
      'title': 'Quiz Results Available',
      'message':
          'Your Japanese Hiragana quiz results are ready! You scored 92%. Great job!',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'icon': Icons.quiz,
      'color': Colors.teal,
      'courseTitle': 'Japanese for Beginners',
      'actionType': 'view_results',
    },
    {
      'id': 'notif_008',
      'type': 'system',
      'title': 'App Update Available',
      'message':
          'A new version of SayHello is available with improved speech recognition features.',
      'time': DateTime.now().subtract(Duration(days: 2)),
      'isRead': true,
      'icon': Icons.system_update,
      'color': Colors.grey,
      'actionType': 'update_app',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get unreadNotifications =>
      allNotifications.where((notif) => !notif['isRead']).toList();

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = allNotifications.indexWhere(
        (notif) => notif['id'] == notificationId,
      );
      if (index != -1) {
        allNotifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in allNotifications) {
        notif['isRead'] = true;
      }
    });
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    _markAsRead(notification['id']);

    // Handle different action types
    switch (notification['actionType']) {
      case 'join_lesson':
        _showActionDialog(
          'Join Lesson',
          'Would you like to join your Japanese lesson now?',
        );
        break;
      case 'view_achievement':
        _showActionDialog(
          'Achievement',
          'View your 7-day streak achievement and share it with friends!',
        );
        break;
      case 'complete_assignment':
        _showActionDialog(
          'Assignment',
          'Open your Spanish conversation practice assignment?',
        );
        break;
      case 'view_progress':
        _showActionDialog(
          'Progress',
          'View your detailed weekly progress report.',
        );
        break;
      case 'view_request':
        _showActionDialog(
          'Study Buddy',
          'Accept Maria\'s study buddy request?',
        );
        break;
      case 'view_course':
        _showActionDialog(
          'Course Update',
          'View new content in German Advanced Grammar course.',
        );
        break;
      case 'view_results':
        _showActionDialog(
          'Quiz Results',
          'View detailed results for your Hiragana quiz.',
        );
        break;
      case 'update_app':
        _showActionDialog(
          'App Update',
          'Update SayHello to the latest version?',
        );
        break;
      default:
        break;
    }
  }

  void _showActionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title action completed!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    bool isDark,
  ) {
    final isUnread = !notification['isRead'];

    return InkWell(
      onTap: () => _handleNotificationAction(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.05))
              : (isDark ? Colors.grey[850] : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey[200]!,
              blurRadius: 4,
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
                color: notification['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                notification['icon'],
                color: notification['color'],
                size: 24,
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
                          notification['title'],
                          style: TextStyle(
                            fontSize: 16,
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
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        _getTimeAgo(notification['time']),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      if (notification['courseTitle'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: notification['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification['courseTitle'],
                            style: TextStyle(
                              fontSize: 10,
                              color: notification['color'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Settings icon
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => SettingsProvider.showSettingsBottomSheet(context),
          ),
          // Mark all as read
          if (unreadNotifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.done_all,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: _markAllAsRead,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: Colors.indigo,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.all),
                  if (allNotifications.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${allNotifications.length}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Unread'),
                  if (unreadNotifications.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${unreadNotifications.length}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Notifications Tab
          allNotifications.isEmpty
              ? _buildEmptyState(isDark, 'No notifications')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: allNotifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(
                      allNotifications[index],
                      isDark,
                    );
                  },
                ),

          // Unread Notifications Tab
          unreadNotifications.isEmpty
              ? _buildEmptyState(isDark, 'No unread notifications')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: unreadNotifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(
                      unreadNotifications[index],
                      isDark,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
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
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! 🎉',
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
