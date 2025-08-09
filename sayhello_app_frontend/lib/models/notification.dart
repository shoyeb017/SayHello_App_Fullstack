/// Model classes for Notification functionality from Supabase
/// Handles push notifications, in-app notifications, and user alerts

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'course', 'chat', 'feed', 'system', 'reminder'
  final String? relatedId; // ID of related course, chat, feed, etc.
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data; // Additional notification payload

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  /// Create AppNotification from JSON (Supabase response)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Convert AppNotification to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'data': data,
    };
  }

  /// Create a copy with modified fields
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? (this.data != null ? Map.from(this.data!) : null),
    );
  }

  /// Mark notification as read
  AppNotification markAsRead() {
    return copyWith(isRead: true, readAt: DateTime.now());
  }

  /// Get notification icon based on type
  String get icon {
    switch (type) {
      case 'course':
        return '📚';
      case 'chat':
        return '💬';
      case 'feed':
        return '📱';
      case 'system':
        return '⚙️';
      case 'reminder':
        return '⏰';
      default:
        return '📬';
    }
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, read: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model for notification preferences/settings
class NotificationSettings {
  final String id;
  final String userId;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool courseReminders;
  final bool chatMessages;
  final bool feedUpdates;
  final bool systemAlerts;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "08:00"
  final DateTime updatedAt;

  const NotificationSettings({
    required this.id,
    required this.userId,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.courseReminders,
    required this.chatMessages,
    required this.feedUpdates,
    required this.systemAlerts,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.updatedAt,
  });

  /// Create NotificationSettings from JSON (Supabase response)
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      courseReminders: json['course_reminders'] as bool? ?? true,
      chatMessages: json['chat_messages'] as bool? ?? true,
      feedUpdates: json['feed_updates'] as bool? ?? true,
      systemAlerts: json['system_alerts'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] as String? ?? '08:00',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert NotificationSettings to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'course_reminders': courseReminders,
      'chat_messages': chatMessages,
      'feed_updates': feedUpdates,
      'system_alerts': systemAlerts,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  NotificationSettings copyWith({
    String? id,
    String? userId,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? courseReminders,
    bool? chatMessages,
    bool? feedUpdates,
    bool? systemAlerts,
    String? quietHoursStart,
    String? quietHoursEnd,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      courseReminders: courseReminders ?? this.courseReminders,
      chatMessages: chatMessages ?? this.chatMessages,
      feedUpdates: feedUpdates ?? this.feedUpdates,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if currently in quiet hours
  bool get isQuietTime {
    final now = TimeOfDay.now();
    final start = _parseTime(quietHoursStart);
    final end = _parseTime(quietHoursEnd);

    // Handle overnight quiet hours (e.g., 22:00 to 08:00)
    if (start.hour > end.hour) {
      return now.hour >= start.hour || now.hour < end.hour;
    } else {
      return now.hour >= start.hour && now.hour < end.hour;
    }
  }

  /// Parse time string to TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toString() {
    return 'NotificationSettings(id: $id, push: $pushNotifications)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Simple time class for quiet hours calculation
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  static TimeOfDay now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }
}

/// Model for notification summary/counts
class NotificationSummary {
  final int totalCount;
  final int unreadCount;
  final int courseNotifications;
  final int chatNotifications;
  final int feedNotifications;
  final int systemNotifications;

  const NotificationSummary({
    required this.totalCount,
    required this.unreadCount,
    required this.courseNotifications,
    required this.chatNotifications,
    required this.feedNotifications,
    required this.systemNotifications,
  });

  /// Create NotificationSummary from JSON
  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      totalCount: json['total_count'] as int? ?? 0,
      unreadCount: json['unread_count'] as int? ?? 0,
      courseNotifications: json['course_notifications'] as int? ?? 0,
      chatNotifications: json['chat_notifications'] as int? ?? 0,
      feedNotifications: json['feed_notifications'] as int? ?? 0,
      systemNotifications: json['system_notifications'] as int? ?? 0,
    );
  }

  /// Check if there are any unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Get badge text for unread count
  String get badgeText {
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  @override
  String toString() {
    return 'NotificationSummary(total: $totalCount, unread: $unreadCount)';
  }
}
