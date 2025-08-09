/// Chat Repository - Handles all chat and messaging database operations
/// Provides CRUD operations for chats and messages with real-time support

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/supabase_config.dart';

class ChatRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  // =============================
  // CHAT OPERATIONS
  // =============================

  /// Create a new chat between two users
  Future<Chat> createChat(String user1Id, String user2Id) async {
    final chatData = {
      'participant_ids': [user1Id, user2Id],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from('chats')
        .insert(chatData)
        .select()
        .single();

    return Chat.fromJson(response);
  }

  /// Get chat by ID
  Future<Chat?> getChatById(String chatId) async {
    final response = await _client
        .from('chats')
        .select()
        .eq('id', chatId)
        .maybeSingle();

    if (response == null) return null;
    return Chat.fromJson(response);
  }

  /// Get or create chat between two users
  Future<Chat?> getChatBetweenUsers(String user1Id, String user2Id) async {
    final response = await _client
        .from('chats')
        .select()
        .contains('participant_ids', [user1Id])
        .contains('participant_ids', [user2Id])
        .maybeSingle();

    if (response == null) return null;
    return Chat.fromJson(response);
  }

  /// Get all chats for a user with latest message and unread count
  Future<List<ChatWithLatestMessage>> getUserChats(String userId) async {
    // Get chats where user is participant
    final chatsResponse = await _client
        .from('chats')
        .select()
        .contains('participant_ids', [userId])
        .order('updated_at', ascending: false);

    List<ChatWithLatestMessage> chatsWithMessages = [];

    for (final chatData in chatsResponse) {
      final chat = Chat.fromJson(chatData);

      // Get latest message
      final latestMessageResponse = await _client
          .from('chat_messages')
          .select()
          .eq('chat_id', chat.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      ChatMessage? latestMessage;
      if (latestMessageResponse != null) {
        latestMessage = ChatMessage.fromJson(latestMessageResponse);
      }

      // Get unread count
      final unreadCount = await _client
          .from('chat_messages')
          .select()
          .eq('chat_id', chat.id)
          .eq('is_read', false)
          .neq('sender_id', userId);

      chatsWithMessages.add(
        ChatWithLatestMessage(
          chat: chat,
          latestMessage: latestMessage,
          unreadCount: (unreadCount as List).length,
        ),
      );
    }

    return chatsWithMessages;
  }

  /// Delete chat and all its messages
  Future<void> deleteChat(String chatId) async {
    // Delete messages first (due to foreign key constraints)
    await _client.from('chat_messages').delete().eq('chat_id', chatId);

    // Delete chat
    await _client.from('chats').delete().eq('id', chatId);
  }

  // =============================
  // MESSAGE OPERATIONS
  // =============================

  /// Send a message
  Future<ChatMessage> sendMessage(ChatMessage message) async {
    final messageData = message.toJson();
    messageData.remove('id'); // Remove ID for creation

    final response = await _client
        .from('chat_messages')
        .insert(messageData)
        .select()
        .single();

    // Update chat's updated_at timestamp
    await _client
        .from('chats')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', message.chatId);

    return ChatMessage.fromJson(response);
  }

  /// Get messages for a chat
  Future<List<ChatMessage>> getChatMessages(
    String chatId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }

  /// Mark all messages in a chat as read for a user
  Future<void> markChatMessagesAsRead(String chatId, String userId) async {
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .neq('sender_id', userId);
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    await _client.from('chat_messages').delete().eq('id', messageId);
  }

  /// Get unread message count for user across all chats
  Future<int> getUnreadMessageCount(String userId) async {
    // Get user's chats
    final userChatsResponse = await _client.from('chats').select('id').contains(
      'participant_ids',
      [userId],
    );

    final chatIds = (userChatsResponse as List)
        .map((chat) => chat['id'] as String)
        .toList();

    if (chatIds.isEmpty) return 0;

    // Count unread messages in user's chats (not sent by user)
    final unreadResponse = await _client
        .from('chat_messages')
        .select()
        .inFilter('chat_id', chatIds)
        .eq('is_read', false)
        .neq('sender_id', userId);

    return (unreadResponse as List).length;
  }

  // =============================
  // REAL-TIME SUBSCRIPTIONS (Commented out due to API compatibility)
  // =============================

  /*
  /// Subscribe to new messages in a chat
  Stream<ChatMessage> subscribeToMessages(String chatId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .map((data) => ChatMessage.fromJson(data.first));
  }

  /// Subscribe to chat updates
  Stream<Chat> subscribeToChat(String chatId) {
    return _client
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('id', chatId)
        .map((data) => Chat.fromJson(data.first));
  }

  /// Subscribe to user's chats
  Stream<List<Chat>> subscribeToUserChats(String userId) {
    return _client
        .from('chats')
        .stream(primaryKey: ['id'])
        .contains('participant_ids', [userId])
        .map((data) => (data as List)
            .map((json) => Chat.fromJson(json))
            .toList());
  }
  */
}
