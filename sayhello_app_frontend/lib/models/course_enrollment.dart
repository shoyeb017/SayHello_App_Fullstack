/// Model class for Course Enrollment data from Supabase
/// Handles the relationship between learners and courses they've enrolled in

import 'course.dart';

class CourseEnrollment {
  final String id;
  final String courseId;
  final String learnerId;
  final DateTime createdAt;

  const CourseEnrollment({
    required this.id,
    required this.courseId,
    required this.learnerId,
    required this.createdAt,
  });

  /// Create CourseEnrollment from JSON (Supabase response)
  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      learnerId: json['learner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert CourseEnrollment to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'learner_id': learnerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  CourseEnrollment copyWith({
    String? id,
    String? courseId,
    String? learnerId,
    DateTime? createdAt,
  }) {
    return CourseEnrollment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      learnerId: learnerId ?? this.learnerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CourseEnrollment(id: $id, courseId: $courseId, learnerId: $learnerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseEnrollment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model class for enrollment with course details (for joined queries)
class EnrollmentWithCourse {
  final CourseEnrollment enrollment;
  final Course course;

  const EnrollmentWithCourse({required this.enrollment, required this.course});

  /// Create EnrollmentWithCourse from JSON with joined data
  factory EnrollmentWithCourse.fromJson(Map<String, dynamic> json) {
    return EnrollmentWithCourse(
      enrollment: CourseEnrollment.fromJson(json),
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'EnrollmentWithCourse(enrollment: ${enrollment.id}, course: ${course.title})';
  }
}
