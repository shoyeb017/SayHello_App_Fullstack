/// Model class for RecordedClass data from backend
/// Handles recorded class information for video links

class RecordedClass {
  final String id;
  final String courseId;
  final String recordedName;
  final String recordedDescription;
  final String recordedLink;
  final DateTime createdAt;

  const RecordedClass({
    required this.id,
    required this.courseId,
    required this.recordedName,
    required this.recordedDescription,
    required this.recordedLink,
    required this.createdAt,
  });

  /// Create RecordedClass from JSON (backend response)
  factory RecordedClass.fromJson(Map<String, dynamic> json) {
    return RecordedClass(
      id: json['id'] ?? json['_id'] ?? '',
      courseId: json['course_id'] ?? '',
      recordedName: json['recorded_name'] ?? '',
      recordedDescription: json['recorded_description'] ?? '',
      recordedLink: json['recorded_link'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert RecordedClass to JSON (for backend insert/update)
  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'recorded_name': recordedName,
      'recorded_description': recordedDescription,
      'recorded_link': recordedLink,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  RecordedClass copyWith({
    String? id,
    String? courseId,
    String? recordedName,
    String? recordedDescription,
    String? recordedLink,
    DateTime? createdAt,
  }) {
    return RecordedClass(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      recordedName: recordedName ?? this.recordedName,
      recordedDescription: recordedDescription ?? this.recordedDescription,
      recordedLink: recordedLink ?? this.recordedLink,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'RecordedClass(id: $id, name: $recordedName, link: $recordedLink)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordedClass && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
