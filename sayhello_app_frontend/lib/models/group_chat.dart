/// GroupChatMessage Model
/// Represents a message in the group chat
/// Matches exactly with the database schema

class GroupChatMessage {
  final String id;
  final String courseId;
  final String senderId;
  final String senderType; // 'learner' or 'instructor' (from enum)
  final String contentText;
  final String? parentMessageId; // For replies
  final DateTime createdAt;

  // Additional fields for UI
  final String? senderName;
  final bool? isOnline;

  GroupChatMessage({
    required this.id,
    required this.courseId,
    required this.senderId,
    required this.senderType,
    required this.contentText,
    this.parentMessageId,
    required this.createdAt,
    this.senderName,
    this.isOnline,
  });

  /// Create GroupChatMessage from JSON (database response)
  factory GroupChatMessage.fromJson(Map<String, dynamic> json) {
    return GroupChatMessage(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderType: json['sender_type']?.toString() ?? '',
      contentText: json['content_text']?.toString() ?? '',
      parentMessageId: json['parent_message_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      senderName: json['sender_name']?.toString(),
      isOnline: json['is_online'] as bool?,
    );
  }

  /// Convert GroupChatMessage to JSON for database operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'sender_id': senderId,
      'sender_type': senderType,
      'content_text': contentText,
      'parent_message_id': parentMessageId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of GroupChatMessage with updated fields
  GroupChatMessage copyWith({
    String? id,
    String? courseId,
    String? senderId,
    String? senderType,
    String? contentText,
    String? parentMessageId,
    DateTime? createdAt,
    String? senderName,
    bool? isOnline,
  }) {
    return GroupChatMessage(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      contentText: contentText ?? this.contentText,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Check if this message is from an instructor
  bool get isFromInstructor => senderType == 'instructor';

  /// Check if this message is from a learner
  bool get isFromLearner => senderType == 'learner';

  /// Check if this message is a reply to another message
  bool get isReply => parentMessageId != null;

  /// Get formatted timestamp for display
  String getFormattedTime() {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour;
    return '${createdAt.month}/${createdAt.day} ${displayHour}:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  String toString() {
    return 'GroupChatMessage{id: $id, senderType: $senderType, contentText: ${contentText.substring(0, contentText.length > 20 ? 20 : contentText.length)}...}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
