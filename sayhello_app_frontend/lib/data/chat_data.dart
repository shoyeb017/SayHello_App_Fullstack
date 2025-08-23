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
    try {
      print('ChatRepository: Creating new chat between $user1Id and $user2Id');

      final chatData = {
        'user1_id': user1Id,
        'user2_id': user2Id,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('ChatRepository: Inserting chat data: $chatData');

      final response = await _client
          .from('chats')
          .insert(chatData)
          .select()
          .single();

      print('ChatRepository: Chat created successfully: $response');

      return Chat.fromJson(response);
    } catch (e) {
      print('ChatRepository: Error creating chat: $e');
      throw Exception('Failed to create chat: $e');
    }
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
    try {
      print('ChatRepository: Looking for chat between $user1Id and $user2Id');

      // Try both combinations since user1_id and user2_id can be in any order
      // Order by created_at desc and limit to 1 to get the most recent chat
      final response = await _client
          .from('chats')
          .select()
          .or(
            'and(user1_id.eq.$user1Id,user2_id.eq.$user2Id),and(user1_id.eq.$user2Id,user2_id.eq.$user1Id)',
          )
          .order('created_at', ascending: false)
          .limit(1);

      print('ChatRepository: getChatBetweenUsers response: $response');

      if (response.isEmpty) {
        print('ChatRepository: No existing chat found');
        return null;
      }

      final chat = Chat.fromJson(response.first);
      print('ChatRepository: Found existing chat: ${chat.id}');
      return chat;
    } catch (e) {
      print('ChatRepository: Error in getChatBetweenUsers: $e');
      throw e;
    }
  }

  /// Get all chats for a user with latest message and unread count
  Future<List<ChatWithLatestMessage>> getUserChats(String userId) async {
    // Get chats where user is participant (either user1_id or user2_id)
    final chatsResponse = await _client
        .from('chats')
        .select()
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('created_at', ascending: false);

    List<ChatWithLatestMessage> chatsWithMessages = [];

    for (final chatData in chatsResponse) {
      final chat = Chat.fromJson(chatData);

      // Get latest message
      final latestMessageResponse = await _client
          .from('messages')
          .select()
          .eq('chat_id', chat.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      ChatMessage? latestMessage;
      if (latestMessageResponse != null) {
        latestMessage = ChatMessage.fromJson(latestMessageResponse);
      }

      // Get unread count (messages not sent by user and status = 'unread')
      final unreadResponse = await _client
          .from('messages')
          .select()
          .eq('chat_id', chat.id)
          .eq('status', 'unread')
          .neq('sender_id', userId);

      chatsWithMessages.add(
        ChatWithLatestMessage(
          chat: chat,
          latestMessage: latestMessage,
          unreadCount: (unreadResponse as List).length,
        ),
      );
    }

    return chatsWithMessages;
  }

  /// Delete chat and all its messages
  Future<void> deleteChat(String chatId) async {
    // Delete messages first (due to foreign key constraints)
    await _client.from('messages').delete().eq('chat_id', chatId);

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
        .from('messages')
        .insert(messageData)
        .select()
        .single();

    return ChatMessage.fromJson(response);
  }

  /// Get messages for a chat
  Future<List<ChatMessage>> getChatMessages(
    String chatId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _client
        .from('messages')
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
        .from('messages')
        .update({'status': 'read'})
        .eq('id', messageId);
  }

  /// Mark all messages in a chat as read for a user
  Future<void> markChatMessagesAsRead(String chatId, String userId) async {
    await _client
        .from('messages')
        .update({'status': 'read'})
        .eq('chat_id', chatId)
        .neq('sender_id', userId);
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    await _client.from('messages').delete().eq('id', messageId);
  }

  /// Get unread message count for user across all chats
  Future<int> getUnreadMessageCount(String userId) async {
    // Get user's chats
    final userChatsResponse = await _client
        .from('chats')
        .select('id')
        .or('user1_id.eq.$userId,user2_id.eq.$userId');

    final chatIds = (userChatsResponse as List)
        .map((chat) => chat['id'] as String)
        .toList();

    if (chatIds.isEmpty) return 0;

    // Count unread messages in user's chats (not sent by user)
    final unreadResponse = await _client
        .from('messages')
        .select()
        .inFilter('chat_id', chatIds)
        .eq('status', 'unread')
        .neq('sender_id', userId);

    return (unreadResponse as List).length;
  }

  /// Update message correction
  Future<void> updateMessageCorrection(
    String messageId,
    String correction,
  ) async {
    await _client
        .from('messages')
        .update({'correction': correction})
        .eq('id', messageId);
  }

  /// Update message translation
  Future<void> updateMessageTranslation(
    String messageId,
    String translation,
  ) async {
    await _client
        .from('messages')
        .update({'translated_content': translation})
        .eq('id', messageId);
  }

  // =============================
  // =============================
  // REAL-TIME SUBSCRIPTIONS
  // =============================

  /// Subscribe to new messages in a chat with callback-based approach
  RealtimeChannel? subscribeToMessages({
    required String chatId,
    required Function(ChatMessage) onMessageReceived,
    Function(ChatMessage)? onMessageUpdated,
    Function(String)? onMessageDeleted,
  }) {
    print(
      'ChatRepository: Setting up real-time subscription for chat: $chatId',
    );

    final channel = _client
        .channel('messages:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            try {
              print('ChatRepository: New message received via real-time');
              final message = ChatMessage.fromJson(payload.newRecord);
              onMessageReceived(message);
            } catch (e) {
              print('ChatRepository: Error parsing new message: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            try {
              print('ChatRepository: Message updated via real-time');
              final message = ChatMessage.fromJson(payload.newRecord);
              onMessageUpdated?.call(message);
            } catch (e) {
              print('ChatRepository: Error parsing updated message: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  /// Subscribe to user's chats
  RealtimeChannel? subscribeToUserChats({
    required String userId,
    required Function(Chat) onChatAdded,
    Function(Chat)? onChatUpdated,
  }) {
    print(
      'ChatRepository: Setting up real-time subscription for user chats: $userId',
    );

    final channel = _client
        .channel('chats:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user1_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              print('ChatRepository: New chat (user1) received via real-time');
              final chat = Chat.fromJson(payload.newRecord);
              onChatAdded(chat);
            } catch (e) {
              print('ChatRepository: Error parsing new chat: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user2_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              print('ChatRepository: New chat (user2) received via real-time');
              final chat = Chat.fromJson(payload.newRecord);
              onChatAdded(chat);
            } catch (e) {
              print('ChatRepository: Error parsing new chat: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  /// Subscribe to message updates that affect chat list (for real-time chat list updates)
  RealtimeChannel? subscribeToMessagesForChatList({
    required String userId,
    required Function(ChatMessage) onNewMessage,
    Function(ChatMessage)? onMessageUpdated,
  }) {
    print(
      'ChatRepository: Setting up real-time subscription for messages affecting chat list for user: $userId',
    );

    final channel = _client
        .channel('messages_for_chat_list:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              print(
                'ChatRepository: New message received via real-time for chat list',
              );
              final message = ChatMessage.fromJson(payload.newRecord);
              onNewMessage(message);
            } catch (e) {
              print(
                'ChatRepository: Error parsing new message for chat list: $e',
              );
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              if (onMessageUpdated != null) {
                print(
                  'ChatRepository: Message updated via real-time for chat list',
                );
                final message = ChatMessage.fromJson(payload.newRecord);
                onMessageUpdated(message);
              }
            } catch (e) {
              print(
                'ChatRepository: Error parsing updated message for chat list: $e',
              );
            }
          },
        )
        .subscribe();

    return channel;
  }
}
