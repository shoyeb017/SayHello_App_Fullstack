/// Model class for RecordClass data from backend
/// Handles record class information for video links

class RecordClass {
  final String id;
  final String courseId;
  final String recordedName;
  final String recordedDescription;
  final String recordedLink;
  final DateTime createdAt;

  const RecordClass({
    required this.id,
    required this.courseId,
    required this.recordedName,
    required this.recordedDescription,
    required this.recordedLink,
    required this.createdAt,
  });

  /// Create RecordClass from JSON (backend response)
  factory RecordClass.fromJson(Map<String, dynamic> json) {
    return RecordClass(
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

  /// Convert RecordClass to JSON (for backend insert/update)
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
  RecordClass copyWith({
    String? id,
    String? courseId,
    String? recordedName,
    String? recordedDescription,
    String? recordedLink,
    DateTime? createdAt,
  }) {
    return RecordClass(
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
    return 'RecordClass(id: $id, name: $recordedName, link: $recordedLink)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordClass && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
