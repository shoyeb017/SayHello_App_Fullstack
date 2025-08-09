/// Model classes for Chat functionality from Supabase
/// Handles chat rooms, messages, and real-time communication

class Chat {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
  final List<String> participantIds;

  const Chat({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.imageUrl,
    required this.participantIds,
  });

  /// Create Chat from JSON (Supabase response)
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      participantIds: List<String>.from(json['participant_ids'] ?? []),
    );
  }

  /// Convert Chat to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'image_url': imageUrl,
      'participant_ids': participantIds,
    };
  }

  /// Create a copy with modified fields
  Chat copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
    List<String>? participantIds,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participantIds: participantIds ?? List.from(this.participantIds),
    );
  }

  /// Get participant count
  int get participantCount => participantIds.length;

  /// Check if user is participant
  bool isParticipant(String userId) => participantIds.contains(userId);

  @override
  String toString() {
    return 'Chat(id: $id, name: $name, participants: ${participantIds.length})';
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
  final String message;
  final DateTime createdAt;
  final String? messageType; // text, image, file, etc.
  final String? fileUrl;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.messageType,
    this.fileUrl,
    required this.isRead,
  });

  /// Create ChatMessage from JSON (Supabase response)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      messageType: json['message_type'] as String?,
      fileUrl: json['file_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  /// Convert ChatMessage to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'message_type': messageType,
      'file_url': fileUrl,
      'is_read': isRead,
    };
  }

  /// Create a copy with modified fields
  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? message,
    DateTime? createdAt,
    String? messageType,
    String? fileUrl,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Check if message is a file/media
  bool get isMediaMessage => fileUrl != null && fileUrl!.isNotEmpty;

  /// Check if message is text only
  bool get isTextMessage => messageType == null || messageType == 'text';

  /// Get formatted time (HH:MM)
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Mark message as read
  ChatMessage markAsRead() => copyWith(isRead: true);

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $senderId, read: $isRead)';
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
    if (latestMessage!.isMediaMessage) return '📎 File';
    return latestMessage!.message;
  }

  @override
  String toString() {
    return 'ChatWithLatestMessage(chat: ${chat.name}, unread: $unreadCount)';
  }
}
