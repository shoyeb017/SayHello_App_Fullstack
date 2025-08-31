/// Notification Provider - State management for notifications
/// Handles notification loading, marking as read, and real-time updates

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';
import '../data/notification_data.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  // Notification state
  List<AppNotification> _notifications = [];
  NotificationSummary? _summary;
  NotificationSettings? _settings;

  // Real-time subscriptions
  RealtimeChannel? _realtimeChannel;

  // Loading states
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Error state
  String? _error;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  NotificationSummary? get summary => _summary;
  NotificationSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get hasError => _error != null;

  // Computed properties
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  bool get hasUnreadNotifications => unreadCount > 0;

  // =============================
  // NOTIFICATION OPERATIONS
  // =============================

  /// Load notifications for a user
  Future<void> loadNotifications(String userId, {int? limit = 50}) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      print('NotificationProvider: Loading notifications for user: $userId');

      _notifications = await _repository.getUserNotifications(
        userId: userId,
        limit: limit,
      );

      print(
        'NotificationProvider: Loaded ${_notifications.length} notifications',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('NotificationProvider: Error loading notifications: $e');
      _setError('Failed to load notifications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load only unread notifications
  Future<void> loadUnreadNotifications(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      print(
        'NotificationProvider: Loading unread notifications for user: $userId',
      );

      _notifications = await _repository.getUserNotifications(
        userId: userId,
        unreadOnly: true,
      );

      print(
        'NotificationProvider: Loaded ${_notifications.length} unread notifications',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('NotificationProvider: Error loading unread notifications: $e');
      _setError('Failed to load unread notifications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    _setUpdating(true);
    _clearError();

    try {
      print(
        'NotificationProvider: Marking notification as read: $notificationId',
      );

      final success = await _repository.markAsRead(notificationId);

      if (success) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].markAsRead();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }

        print('NotificationProvider: Notification marked as read successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('NotificationProvider: Error marking notification as read: $e');
      _setError('Failed to mark notification as read: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    _setUpdating(true);
    _clearError();

    try {
      print(
        'NotificationProvider: Marking all notifications as read for user: $userId',
      );

      final success = await _repository.markAllAsRead(userId);

      if (success) {
        // Update all local notifications
        _notifications = _notifications.map((n) => n.markAsRead()).toList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });

        print(
          'NotificationProvider: All notifications marked as read successfully',
        );
        return true;
      }

      return false;
    } catch (e) {
      print(
        'NotificationProvider: Error marking all notifications as read: $e',
      );
      _setError('Failed to mark all notifications as read: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    _setDeleting(true);
    _clearError();

    try {
      print('NotificationProvider: Deleting notification: $notificationId');

      final success = await _repository.deleteNotification(notificationId);

      if (success) {
        // Remove from local list
        _notifications.removeWhere((n) => n.id == notificationId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });

        print('NotificationProvider: Notification deleted successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('NotificationProvider: Error deleting notification: $e');
      _setError('Failed to delete notification: ${e.toString()}');
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  /// Create a new notification
  Future<AppNotification?> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('NotificationProvider: Creating notification for user: $userId');

      final notification = await _repository.createNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        relatedId: relatedId,
        data: data,
      );

      // Add to local list (real-time will also add it, but this provides immediate feedback)
      _notifications.insert(0, notification);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      print('NotificationProvider: Notification created successfully');
      return notification;
    } catch (e) {
      print('NotificationProvider: Error creating notification: $e');
      _setError('Failed to create notification: ${e.toString()}');
      return null;
    }
  }

  // =============================
  // NOTIFICATION SUMMARY
  // =============================

  /// Load notification summary
  Future<void> loadSummary(String userId) async {
    try {
      print(
        'NotificationProvider: Loading notification summary for user: $userId',
      );

      _summary = await _repository.getNotificationSummary(userId);

      print(
        'NotificationProvider: Summary loaded - Total: ${_summary?.totalCount}, Unread: ${_summary?.unreadCount}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('NotificationProvider: Error loading summary: $e');
      _setError('Failed to load notification summary: ${e.toString()}');
    }
  }

  // =============================
  // NOTIFICATION SETTINGS
  // =============================

  /// Load notification settings
  Future<void> loadSettings(String userId) async {
    try {
      print(
        'NotificationProvider: Loading notification settings for user: $userId',
      );

      _settings = await _repository.getNotificationSettings(userId);

      print('NotificationProvider: Settings loaded successfully');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('NotificationProvider: Error loading settings: $e');
      _setError('Failed to load notification settings: ${e.toString()}');
    }
  }

  /// Update notification settings
  Future<bool> updateSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    _setUpdating(true);
    _clearError();

    try {
      print(
        'NotificationProvider: Updating notification settings for user: $userId',
      );

      _settings = await _repository.updateNotificationSettings(userId, updates);

      print('NotificationProvider: Settings updated successfully');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      print('NotificationProvider: Error updating settings: $e');
      _setError('Failed to update notification settings: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // =============================
  // REAL-TIME UPDATES
  // =============================

  /// Subscribe to real-time notification updates
  void subscribeToRealTimeUpdates(String userId) {
    if (_realtimeChannel != null) {
      unsubscribeFromRealTimeUpdates();
    }

    print(
      'NotificationProvider: Subscribing to real-time updates for user: $userId',
    );

    _realtimeChannel = _repository.subscribeToNotifications(
      userId: userId,
      onNotificationReceived: (notification) {
        print(
          'NotificationProvider: Real-time notification received: ${notification.id}',
        );

        // Check if notification already exists (to avoid duplicates)
        if (!_notifications.any((n) => n.id == notification.id)) {
          _notifications.insert(0, notification);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      },
      onNotificationUpdated: (notification) {
        print(
          'NotificationProvider: Real-time notification updated: ${notification.id}',
        );

        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      },
      onNotificationDeleted: (notificationId) {
        print(
          'NotificationProvider: Real-time notification deleted: $notificationId',
        );

        _notifications.removeWhere((n) => n.id == notificationId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      },
    );
  }

  /// Unsubscribe from real-time updates
  void unsubscribeFromRealTimeUpdates() {
    if (_realtimeChannel != null) {
      print('NotificationProvider: Unsubscribing from real-time updates');
      _repository.unsubscribeFromNotifications(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  // =============================
  // CONVENIENCE METHODS
  // =============================

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<AppNotification> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications.where((n) => n.createdAt.isAfter(yesterday)).toList();
  }

  /// Check if notification exists
  bool hasNotification(String notificationId) {
    return _notifications.any((n) => n.id == notificationId);
  }

  /// Clear all notifications
  void clearNotifications() {
    print('NotificationProvider: Clearing all notifications');
    _notifications.clear();
    _summary = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Refresh notifications (reload from server)
  Future<void> refreshNotifications(String userId) async {
    print('NotificationProvider: Refreshing notifications...');
    await loadNotifications(userId);
  }

  // =============================
  // HELPER METHODS FOR AUTOMATIC NOTIFICATIONS
  // =============================

  /// Create course notification
  Future<void> createCourseNotification({
    required String userId,
    required String courseId,
    required String courseName,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    await _repository.createCourseNotification(
      userId: userId,
      courseId: courseId,
      courseName: courseName,
      type: type,
      additionalData: additionalData,
    );
  }

  // =============================
  // PRIVATE HELPER METHODS
  // =============================

  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String? error) {
    _error = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    unsubscribeFromRealTimeUpdates();
    super.dispose();
  }
}
