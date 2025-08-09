/// Model class for Course Portal data from Supabase
/// Handles portal content, video lessons, and course materials

import 'course.dart';

class CoursePortal {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? materialPath;
  final String? language;
  final int order;
  final DateTime createdAt;

  const CoursePortal({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.videoUrl,
    this.materialPath,
    this.language,
    required this.order,
    required this.createdAt,
  });

  /// Create CoursePortal from JSON (Supabase response)
  factory CoursePortal.fromJson(Map<String, dynamic> json) {
    return CoursePortal(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      materialPath: json['material_path'] as String?,
      language: json['language'] as String?,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert CoursePortal to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'material_path': materialPath,
      'language': language,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  CoursePortal copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? videoUrl,
    String? materialPath,
    String? language,
    int? order,
    DateTime? createdAt,
  }) {
    return CoursePortal(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      materialPath: materialPath ?? this.materialPath,
      language: language ?? this.language,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if portal has video content
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// Check if portal has material files
  bool get hasMaterials => materialPath != null && materialPath!.isNotEmpty;

  /// Get display language or default
  String get displayLanguage => language ?? 'English';

  @override
  String toString() {
    return 'CoursePortal(id: $id, title: $title, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoursePortal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model for course portal with additional metadata
class CoursePortalDetail extends CoursePortal {
  final Course course;
  final bool isCompleted;
  final Duration? videoDuration;

  const CoursePortalDetail({
    required super.id,
    required super.courseId,
    required super.title,
    super.description,
    super.videoUrl,
    super.materialPath,
    super.language,
    required super.order,
    required super.createdAt,
    required this.course,
    required this.isCompleted,
    this.videoDuration,
  });

  /// Create CoursePortalDetail from JSON with course data
  factory CoursePortalDetail.fromJson(
    Map<String, dynamic> json, {
    required Course course,
    bool isCompleted = false,
    Duration? videoDuration,
  }) {
    final portal = CoursePortal.fromJson(json);
    return CoursePortalDetail(
      id: portal.id,
      courseId: portal.courseId,
      title: portal.title,
      description: portal.description,
      videoUrl: portal.videoUrl,
      materialPath: portal.materialPath,
      language: portal.language,
      order: portal.order,
      createdAt: portal.createdAt,
      course: course,
      isCompleted: isCompleted,
      videoDuration: videoDuration,
    );
  }

  /// Get formatted video duration
  String get formattedDuration {
    if (videoDuration == null) return 'Unknown';
    final minutes = videoDuration!.inMinutes;
    final seconds = videoDuration!.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'CoursePortalDetail(id: $id, title: $title, completed: $isCompleted)';
  }
}
