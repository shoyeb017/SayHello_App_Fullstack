/// Notification Repository - Backend operations for notifications
/// Handles database operations for user notifications, settings, and preferences

import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../models/notification.dart';

class NotificationRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get notifications for a specific user
  Future<List<AppNotification>> getUserNotifications({
    required String userId,
    int? limit = 50,
    bool? unreadOnly,
  }) async {
    try {
      print('NotificationRepository: Loading notifications for user: $userId');

      var query = _client.from('notifications').select().eq('user_id', userId);

      if (unreadOnly == true) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit ?? 50);

      print('NotificationRepository: Loaded ${response.length} notifications');

      return response
          .map<AppNotification>((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('NotificationRepository: Error loading notifications: $e');
      throw e;
    }
  }

  /// Create a new notification
  Future<AppNotification> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('NotificationRepository: Creating notification for user: $userId');

      final notification = {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'related_id': relatedId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'data': data,
      };

      final response = await _client
          .from('notifications')
          .insert(notification)
          .select()
          .single();

      print('NotificationRepository: Notification created successfully');

      return AppNotification.fromJson(response);
    } catch (e) {
      print('NotificationRepository: Error creating notification: $e');
      throw e;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      print(
        'NotificationRepository: Marking notification as read: $notificationId',
      );

      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      print('NotificationRepository: Notification marked as read');
      return true;
    } catch (e) {
      print('NotificationRepository: Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllAsRead(String userId) async {
    try {
      print(
        'NotificationRepository: Marking all notifications as read for user: $userId',
      );

      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);

      print('NotificationRepository: All notifications marked as read');
      return true;
    } catch (e) {
      print(
        'NotificationRepository: Error marking all notifications as read: $e',
      );
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      print('NotificationRepository: Deleting notification: $notificationId');

      await _client.from('notifications').delete().eq('id', notificationId);

      print('NotificationRepository: Notification deleted successfully');
      return true;
    } catch (e) {
      print('NotificationRepository: Error deleting notification: $e');
      return false;
    }
  }

  /// Get notification summary/counts
  Future<NotificationSummary> getNotificationSummary(String userId) async {
    try {
      print(
        'NotificationRepository: Loading notification summary for user: $userId',
      );

      // Get total count and unread count
      final totalResponse = await _client
          .from('notifications')
          .select('id, is_read, type')
          .eq('user_id', userId);

      final totalCount = totalResponse.length;
      final unreadCount = totalResponse
          .where((n) => n['is_read'] == false)
          .length;

      // Count by type
      final courseNotifications = totalResponse
          .where((n) => n['type'] == 'course')
          .length;
      final chatNotifications = totalResponse
          .where((n) => n['type'] == 'chat')
          .length;
      final feedNotifications = totalResponse
          .where((n) => n['type'] == 'feed')
          .length;
      final systemNotifications = totalResponse
          .where((n) => n['type'] == 'system')
          .length;

      print(
        'NotificationRepository: Summary - Total: $totalCount, Unread: $unreadCount',
      );

      return NotificationSummary(
        totalCount: totalCount,
        unreadCount: unreadCount,
        courseNotifications: courseNotifications,
        chatNotifications: chatNotifications,
        feedNotifications: feedNotifications,
        systemNotifications: systemNotifications,
      );
    } catch (e) {
      print('NotificationRepository: Error loading notification summary: $e');
      throw e;
    }
  }

  /// Get notification settings for a user
  Future<NotificationSettings?> getNotificationSettings(String userId) async {
    try {
      print(
        'NotificationRepository: Loading notification settings for user: $userId',
      );

      final response = await _client
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        print('NotificationRepository: No settings found, creating default');
        return await createDefaultNotificationSettings(userId);
      }

      print('NotificationRepository: Settings loaded successfully');
      return NotificationSettings.fromJson(response);
    } catch (e) {
      print('NotificationRepository: Error loading notification settings: $e');
      throw e;
    }
  }

  /// Create default notification settings for a user
  Future<NotificationSettings> createDefaultNotificationSettings(
    String userId,
  ) async {
    try {
      print(
        'NotificationRepository: Creating default notification settings for user: $userId',
      );

      final settings = {
        'user_id': userId,
        'push_notifications': true,
        'email_notifications': true,
        'course_reminders': true,
        'chat_messages': true,
        'feed_updates': true,
        'system_alerts': true,
        'quiet_hours_start': '22:00',
        'quiet_hours_end': '08:00',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('notification_settings')
          .insert(settings)
          .select()
          .single();

      print('NotificationRepository: Default settings created successfully');
      return NotificationSettings.fromJson(response);
    } catch (e) {
      print('NotificationRepository: Error creating default settings: $e');
      throw e;
    }
  }

  /// Update notification settings
  Future<NotificationSettings> updateNotificationSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print(
        'NotificationRepository: Updating notification settings for user: $userId',
      );

      final updatedSettings = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('notification_settings')
          .update(updatedSettings)
          .eq('user_id', userId)
          .select()
          .single();

      print('NotificationRepository: Settings updated successfully');
      return NotificationSettings.fromJson(response);
    } catch (e) {
      print('NotificationRepository: Error updating settings: $e');
      throw e;
    }
  }

  /// Subscribe to real-time notification updates
  RealtimeChannel subscribeToNotifications({
    required String userId,
    required Function(AppNotification) onNotificationReceived,
    required Function(AppNotification) onNotificationUpdated,
    required Function(String) onNotificationDeleted,
  }) {
    print(
      'NotificationRepository: Subscribing to real-time notifications for user: $userId',
    );

    final channel = _client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print('NotificationRepository: New notification received');
            final notification = AppNotification.fromJson(payload.newRecord);
            onNotificationReceived(notification);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print('NotificationRepository: Notification updated');
            final notification = AppNotification.fromJson(payload.newRecord);
            onNotificationUpdated(notification);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print('NotificationRepository: Notification deleted');
            final notificationId = payload.oldRecord['id'] as String;
            onNotificationDeleted(notificationId);
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from real-time updates
  void unsubscribeFromNotifications(RealtimeChannel channel) {
    print('NotificationRepository: Unsubscribing from real-time notifications');
    channel.unsubscribe();
  }

  /// Generate automatic notifications for course activities
  Future<void> createCourseNotification({
    required String userId,
    required String courseId,
    required String courseName,
    required String type, // 'session_alert', 'feedback', 'reminder'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String title;
      String message;

      switch (type) {
        case 'session_alert':
          title = 'New Session Available';
          message = 'A new session is available for $courseName';
          break;
        case 'feedback':
          title = 'Course Feedback Received';
          message = 'You have received feedback for $courseName';
          break;
        case 'reminder':
          title = 'Course Reminder';
          message = 'Don\'t forget about your $courseName session';
          break;
        default:
          title = 'Course Update';
          message = 'Update for $courseName';
      }

      await createNotification(
        userId: userId,
        title: title,
        message: message,
        type: 'course',
        relatedId: courseId,
        data: {
          'course_name': courseName,
          'notification_type': type,
          ...?additionalData,
        },
      );
    } catch (e) {
      print('NotificationRepository: Error creating course notification: $e');
    }
  }
}
