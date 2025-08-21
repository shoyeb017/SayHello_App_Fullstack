/// StudyMaterial Model
/// Represents a study material document/file uploaded by instructors
/// Matches exactly with the database schema

class StudyMaterial {
  final String id;
  final String courseId;
  final String materialTitle;
  final String materialDescription;
  final String materialLink;
  final String materialType; // pdf, document, image (from enum)
  final DateTime createdAt;

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.materialTitle,
    required this.materialDescription,
    required this.materialLink,
    required this.materialType,
    required this.createdAt,
  });

  /// Create StudyMaterial from JSON (database response)
  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      materialTitle: json['material_title']?.toString() ?? '',
      materialDescription: json['material_description']?.toString() ?? '',
      materialLink: json['material_link']?.toString() ?? '',
      materialType: json['material_type']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert StudyMaterial to JSON for database operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'material_title': materialTitle,
      'material_description': materialDescription,
      'material_link': materialLink,
      'material_type': materialType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of StudyMaterial with updated fields
  StudyMaterial copyWith({
    String? id,
    String? courseId,
    String? materialTitle,
    String? materialDescription,
    String? materialLink,
    String? materialType,
    DateTime? createdAt,
  }) {
    return StudyMaterial(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      materialTitle: materialTitle ?? this.materialTitle,
      materialDescription: materialDescription ?? this.materialDescription,
      materialLink: materialLink ?? this.materialLink,
      materialType: materialType ?? this.materialType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'StudyMaterial{id: $id, materialTitle: $materialTitle, materialType: $materialType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyMaterial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
