import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/notification.dart';
import '../../../models/learner.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null &&
        authProvider.currentUser is Learner) {
      final currentUser = authProvider.currentUser as Learner;

      // Load notifications and subscribe to real-time updates
      await notificationProvider.loadNotifications(currentUser.id);
      notificationProvider.subscribeToRealTimeUpdates(currentUser.id);
    }
  }

  @override
  void dispose() {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.unsubscribeFromRealTimeUpdates();
    super.dispose();
  }

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

  String _getNotificationTitle(AppNotification notification) {
    switch (notification.type) {
      case 'course':
        final notificationType =
            notification.data?['notification_type'] ?? 'update';
        switch (notificationType) {
          case 'session_alert':
            return AppLocalizations.of(context)!.newSessionAvailable;
          case 'feedback':
            return AppLocalizations.of(context)!.courseFeedbackReceived;
          default:
            return notification.title;
        }
      case 'chat':
        return 'New Message';
      case 'feed':
        return 'Feed Update';
      case 'system':
        return 'System Alert';
      default:
        return notification.title;
    }
  }

  String _getNotificationContent(AppNotification notification) {
    // Use the notification message directly, as it's already formatted
    return notification.message;
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isRead) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.markAsRead(notification.id);
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null &&
        authProvider.currentUser is Learner) {
      final currentUser = authProvider.currentUser as Learner;
      await notificationProvider.markAllAsRead(currentUser.id);
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.deleteNotification(notification.id);
  }

  Widget _buildNotificationCard(AppNotification notification, bool isDark) {
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: () => _markAsRead(notification),
      onLongPress: () => _showNotificationOptions(notification),
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
                _getNotificationIcon(notification),
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
                    _getTimeAgo(notification.createdAt),
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

  IconData _getNotificationIcon(AppNotification notification) {
    switch (notification.type) {
      case 'course':
        final notificationType =
            notification.data?['notification_type'] ?? 'update';
        switch (notificationType) {
          case 'session_alert':
            return Icons.schedule;
          case 'feedback':
            return Icons.star_rate;
          default:
            return Icons.school;
        }
      case 'chat':
        return Icons.message;
      case 'feed':
        return Icons.feed;
      case 'system':
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  void _showNotificationOptions(AppNotification notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead)
              ListTile(
                leading: Icon(Icons.mark_email_read),
                title: Text('Mark as Read'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(notification);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification);
              },
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
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.hasUnreadNotifications) {
                return IconButton(
                  icon: Icon(
                    Icons.mark_email_read,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: _markAllAsRead,
                  tooltip: 'Mark all as read',
                );
              }
              return SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => SettingsProvider.showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF7A54FF)),
            );
          }

          if (notificationProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationProvider.error ?? 'Unknown error',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notifications = notificationProvider.notifications;
          final unreadCount = notificationProvider.unreadCount;

          return Column(
            children: [
              // Header with unread count
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                    : RefreshIndicator(
                        color: Color(0xFF7A54FF),
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(
                              notifications[index],
                              isDark,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
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
