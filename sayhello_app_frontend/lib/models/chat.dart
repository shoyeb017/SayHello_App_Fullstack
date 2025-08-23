/// Model classes for Chat functionality from Supabase
/// Handles chat rooms, messages, and real-time communication

class Chat {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
  });

  /// Create Chat from JSON (Supabase response)
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Chat to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Chat copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? createdAt,
  }) {
    return Chat(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get participant IDs as list (for compatibility)
  List<String> get participantIds => [user1Id, user2Id];

  /// Get participant count
  int get participantCount => 2;

  /// Check if user is participant
  bool isParticipant(String userId) => userId == user1Id || userId == user2Id;

  /// Get other participant ID
  String getOtherParticipant(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  @override
  String toString() {
    return 'Chat(id: $id, user1: $user1Id, user2: $user2Id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String? contentText;
  final String type; // message_type_enum: 'text', 'image'
  final String status; // message_status_enum: 'read', 'unread'
  final String? correction;
  final String? translatedContent;
  final String? parentMsgId;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.contentText,
    required this.type,
    required this.status,
    this.correction,
    this.translatedContent,
    this.parentMsgId,
    required this.createdAt,
  });

  /// Create ChatMessage from JSON (Supabase response)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      contentText: json['content_text'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      correction: json['correction'] as String?,
      translatedContent: json['translated_content'] as String?,
      parentMsgId: json['parent_msg_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert ChatMessage to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content_text': contentText,
      'type': type,
      'status': status,
      'correction': correction,
      'translated_content': translatedContent,
      'parent_msg_id': parentMsgId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? contentText,
    String? type,
    String? status,
    String? correction,
    String? translatedContent,
    String? parentMsgId,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      contentText: contentText ?? this.contentText,
      type: type ?? this.type,
      status: status ?? this.status,
      correction: correction ?? this.correction,
      translatedContent: translatedContent ?? this.translatedContent,
      parentMsgId: parentMsgId ?? this.parentMsgId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Compatibility getters for old API
  String get message => contentText ?? '';
  String? get messageType => type;
  String? get fileUrl => type == 'image' ? contentText : null;
  bool get isRead => status == 'read';

  /// Check if message is a file/media
  bool get isMediaMessage => type == 'image';

  /// Check if message is text only
  bool get isTextMessage => type == 'text';

  /// Get formatted time (HH:MM)
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Mark message as read
  ChatMessage markAsRead() => copyWith(status: 'read');

  /// Check if message is a reply
  bool get isReply => parentMsgId != null;

  /// Check if message has correction
  bool get hasCorrection => correction != null && correction!.isNotEmpty;

  /// Check if message has translation
  bool get hasTranslation =>
      translatedContent != null && translatedContent!.isNotEmpty;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $senderId, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model for chat with latest message info
class ChatWithLatestMessage {
  final Chat chat;
  final ChatMessage? latestMessage;
  final int unreadCount;

  const ChatWithLatestMessage({
    required this.chat,
    this.latestMessage,
    required this.unreadCount,
  });

  /// Create ChatWithLatestMessage from JSON
  factory ChatWithLatestMessage.fromJson(Map<String, dynamic> json) {
    return ChatWithLatestMessage(
      chat: Chat.fromJson(json),
      latestMessage: json['latest_message'] != null
          ? ChatMessage.fromJson(json['latest_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// Check if chat has unread messages
  bool get hasUnread => unreadCount > 0;

  /// Get display text for latest message
  String get latestMessageDisplay {
    if (latestMessage == null) return 'No messages yet';
    if (latestMessage!.isMediaMessage) return '📎 Image';
    return latestMessage!.message;
  }

  @override
  String toString() {
    return 'ChatWithLatestMessage(chat: ${chat.id}, unread: $unreadCount)';
  }
}
