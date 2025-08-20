/// Model class for Course Session data from backend
/// Handles course session information for online meetings

class CourseSession {
  final String id;
  final String courseId;
  final String sessionName;
  final String sessionDescription;
  final DateTime sessionDate;
  final String sessionTime;
  final String sessionDuration;
  final String sessionLink;
  final String? sessionPassword;
  final String sessionPlatform; // 'meet' or 'zoom'
  final DateTime createdAt;

  const CourseSession({
    required this.id,
    required this.courseId,
    required this.sessionName,
    required this.sessionDescription,
    required this.sessionDate,
    required this.sessionTime,
    required this.sessionDuration,
    required this.sessionLink,
    this.sessionPassword,
    required this.sessionPlatform,
    required this.createdAt,
  });

  /// Create CourseSession from JSON (backend response)
  factory CourseSession.fromJson(Map<String, dynamic> json) {
    return CourseSession(
      id: json['id'] ?? json['_id'] ?? '',
      courseId: json['course_id'] ?? '',
      sessionName: json['session_name'] ?? '',
      sessionDescription: json['session_description'] ?? '',
      sessionDate: DateTime.parse(
        json['session_date'] ?? DateTime.now().toIso8601String(),
      ),
      sessionTime: json['session_time'] ?? '',
      sessionDuration: json['session_duration'] ?? '',
      sessionLink: json['session_link'] ?? '',
      sessionPassword: json['session_password'],
      sessionPlatform: json['session_platform'] ?? 'zoom',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert CourseSession to JSON (for backend insert/update)
  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'session_name': sessionName,
      'session_description': sessionDescription,
      'session_date': sessionDate.toIso8601String(),
      'session_time': sessionTime,
      'session_duration': sessionDuration,
      'session_link': sessionLink,
      'session_password': sessionPassword,
      'session_platform': sessionPlatform,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  CourseSession copyWith({
    String? id,
    String? courseId,
    String? sessionName,
    String? sessionDescription,
    DateTime? sessionDate,
    String? sessionTime,
    String? sessionDuration,
    String? sessionLink,
    String? sessionPassword,
    String? sessionPlatform,
    DateTime? createdAt,
  }) {
    return CourseSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sessionName: sessionName ?? this.sessionName,
      sessionDescription: sessionDescription ?? this.sessionDescription,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionTime: sessionTime ?? this.sessionTime,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      sessionLink: sessionLink ?? this.sessionLink,
      sessionPassword: sessionPassword ?? this.sessionPassword,
      sessionPlatform: sessionPlatform ?? this.sessionPlatform,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get session status based on current date and time
  String get status {
    final now = DateTime.now();
    final sessionDateTime = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      _parseTimeOfDay(sessionTime).hour,
      _parseTimeOfDay(sessionTime).minute,
    );

    if (sessionDateTime.isAfter(now)) {
      return 'scheduled';
    } else {
      // Session has passed
      return 'completed';
    }
  }

  /// Parse time string to TimeOfDay equivalent
  _TimeOfDay _parseTimeOfDay(String timeString) {
    try {
      // Handle both 12-hour and 24-hour formats
      String cleanTime = timeString.trim().toLowerCase();
      bool isPM = cleanTime.contains('pm');
      bool isAM = cleanTime.contains('am');

      String timePart = cleanTime.replaceAll(RegExp(r'[^\d:]'), '');
      List<String> parts = timePart.split(':');

      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (isPM && hour != 12) hour += 12;
        if (isAM && hour == 12) hour = 0;

        return _TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return default if parsing fails
    }
    return const _TimeOfDay(hour: 0, minute: 0);
  }

  /// Check if session is upcoming
  bool get isUpcoming => status == 'scheduled';

  /// Check if session is completed
  bool get isCompleted => status == 'completed';

  /// Get formatted date string
  String get formattedDate {
    return '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}';
  }

  /// Get display platform name
  String get displayPlatform {
    switch (sessionPlatform.toLowerCase()) {
      case 'zoom':
        return 'Zoom';
      case 'meet':
        return 'Google Meet';
      case 'teams':
        return 'Teams';
      default:
        return sessionPlatform;
    }
  }

  @override
  String toString() {
    return 'CourseSession(id: $id, name: $sessionName, platform: $sessionPlatform, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// TimeOfDay helper class for time parsing
class _TimeOfDay {
  final int hour;
  final int minute;

  const _TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
