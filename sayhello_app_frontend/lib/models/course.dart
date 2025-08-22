/// Model class for Course data from Supabase
/// Handles course information created by instructors

class Course {
  final String id;
  final String instructorId;
  final String title;
  final String description;
  final String language; // 'english', 'spanish', 'japanese', 'korean', 'bangla'
  final String level; // 'Beginner', 'Intermediate', 'Advanced'
  final int totalSessions;
  final double price;
  final String? thumbnailUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'upcoming', 'active', 'expired'
  final DateTime createdAt;
  final int enrolledStudents; // Count of enrolled students

  const Course({
    required this.id,
    required this.instructorId,
    required this.title,
    required this.description,
    required this.language,
    required this.level,
    required this.totalSessions,
    required this.price,
    this.thumbnailUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.enrolledStudents = 0, // Default to 0 if not provided
  });

  /// Create Course from JSON (Supabase response)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      instructorId: json['instructor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      level: json['level'] as String,
      totalSessions: json['total_sessions'] as int,
      price: (json['price'] as num).toDouble(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      enrolledStudents: json['enrolled_students'] as int? ?? 0,
    );
  }

  /// Convert Course to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'language': language,
      'level': level,
      'total_sessions': totalSessions,
      'price': price,
      'thumbnail_url': thumbnailUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'enrolled_students': enrolledStudents,
    };
  }

  /// Create a copy with modified fields
  Course copyWith({
    String? id,
    String? instructorId,
    String? title,
    String? description,
    String? language,
    String? level,
    int? totalSessions,
    double? price,
    String? thumbnailUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    int? enrolledStudents,
  }) {
    return Course(
      id: id ?? this.id,
      instructorId: instructorId ?? this.instructorId,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      level: level ?? this.level,
      totalSessions: totalSessions ?? this.totalSessions,
      price: price ?? this.price,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
    );
  }

  /// Calculate course duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  /// Check if course is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        status == 'active';
  }

  /// Check if course has started
  bool get hasStarted {
    return DateTime.now().isAfter(startDate);
  }

  /// Check if course has ended
  bool get hasEnded {
    return DateTime.now().isAfter(endDate);
  }

  @override
  String toString() {
    return 'Course(id: $id, title: $title, instructor: $instructorId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
