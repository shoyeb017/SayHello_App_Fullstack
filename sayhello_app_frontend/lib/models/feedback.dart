/// Feedback Model - Handles feedback data structure
/// Supports both course and instructor feedback with ratings

class Feedback {
  final String id;
  final String courseId;
  final String instructorId;
  final String learnerId;
  final FeedbackType feedbackType;
  final String feedbackText;
  final String feedbackAbout;
  final int rating;
  final DateTime createdAt;

  // Additional properties for UI display
  final String? learnerName;
  final String? learnerAvatar;
  final String? instructorName;
  final String? courseName;

  const Feedback({
    required this.id,
    required this.courseId,
    required this.instructorId,
    required this.learnerId,
    required this.feedbackType,
    required this.feedbackText,
    required this.feedbackAbout,
    required this.rating,
    required this.createdAt,
    this.learnerName,
    this.learnerAvatar,
    this.instructorName,
    this.courseName,
  });

  /// Create Feedback from JSON (backend response)
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      instructorId: json['instructor_id'] ?? '',
      learnerId: json['learner_id'] ?? '',
      feedbackType: _parseFeedbackType(json['feedback_type']),
      feedbackText: json['feedback_text'] ?? '',
      feedbackAbout: json['feedback_about'] ?? '',
      rating: json['rating'] ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      learnerName: json['learner_name'],
      learnerAvatar: json['learner_avatar'],
      instructorName: json['instructor_name'],
      courseName: json['course_name'],
    );
  }

  /// Convert Feedback to JSON (for backend requests)
  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'instructor_id': instructorId,
      'learner_id': learnerId,
      'feedback_type': feedbackType.value,
      'feedback_text': feedbackText,
      'feedback_about': feedbackAbout,
      'rating': rating,
    };
  }

  /// Create a copy with modified fields
  Feedback copyWith({
    String? id,
    String? courseId,
    String? instructorId,
    String? learnerId,
    FeedbackType? feedbackType,
    String? feedbackText,
    String? feedbackAbout,
    int? rating,
    DateTime? createdAt,
    String? learnerName,
    String? learnerAvatar,
    String? instructorName,
    String? courseName,
  }) {
    return Feedback(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      instructorId: instructorId ?? this.instructorId,
      learnerId: learnerId ?? this.learnerId,
      feedbackType: feedbackType ?? this.feedbackType,
      feedbackText: feedbackText ?? this.feedbackText,
      feedbackAbout: feedbackAbout ?? this.feedbackAbout,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      learnerName: learnerName ?? this.learnerName,
      learnerAvatar: learnerAvatar ?? this.learnerAvatar,
      instructorName: instructorName ?? this.instructorName,
      courseName: courseName ?? this.courseName,
    );
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get rating color based on value
  String get ratingColor {
    if (rating >= 5) return '#4CAF50'; // Green
    if (rating >= 4) return '#8BC34A'; // Light Green
    if (rating >= 3) return '#FF9800'; // Orange
    if (rating >= 2) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }

  /// Get feedback type display name
  String get feedbackTypeDisplay {
    switch (feedbackType) {
      case FeedbackType.course:
        return 'Course Review';
      case FeedbackType.instructor:
        return 'Instructor Review';
      case FeedbackType.learner:
        return 'Student Feedback';
      case FeedbackType.general:
        return 'General Feedback';
    }
  }

  /// Check if rating is positive (>= 4)
  bool get isPositive => rating >= 4;

  /// Parse feedback type from string
  static FeedbackType _parseFeedbackType(String? type) {
    switch (type?.toLowerCase()) {
      case 'course':
        return FeedbackType.course;
      case 'instructor':
        return FeedbackType.instructor;
      case 'learner':
        return FeedbackType.learner;
      case 'general':
        return FeedbackType.general;
      default:
        return FeedbackType.general;
    }
  }

  @override
  String toString() {
    return 'Feedback(id: $id, type: $feedbackType, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feedback && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Feedback Type Enum
enum FeedbackType {
  course('course'),
  instructor('instructor'),
  learner('learner'),
  general('general');

  const FeedbackType(this.value);
  final String value;
}
