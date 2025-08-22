/// GroupChat Repository - Handles backend operations for group chat
/// Provides CRUD operations with Supabase database integration

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_chat_message.dart';

class GroupChatRepository {
  static final GroupChatRepository _instance = GroupChatRepository._internal();
  factory GroupChatRepository() => _instance;
  GroupChatRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'group_chat';

  /// Get all messages for a specific course
  Future<List<GroupChatMessage>> getMessages(String courseId) async {
    try {
      print('GroupChatRepository: Loading messages for course: $courseId');

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: true);

      print('GroupChatRepository: Response: $response');

      final List<GroupChatMessage> messages = (response as List)
          .map((json) => GroupChatMessage.fromJson(json))
          .toList();

      print('GroupChatRepository: Loaded ${messages.length} messages');
      return messages;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to load messages: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to load messages: $e');
    }
  }

  /// Send a new message
  Future<GroupChatMessage> sendMessage({
    required String courseId,
    required String senderId,
    required String senderType,
    required String contentText,
    String? parentMessageId,
  }) async {
    try {
      print('GroupChatRepository: Sending message...');

      final response = await _supabase
          .from(tableName)
          .insert({
            'course_id': courseId,
            'sender_id': senderId,
            'sender_type': senderType,
            'content_text': contentText,
            'parent_message_id': parentMessageId,
          })
          .select()
          .single();

      print('GroupChatRepository: Message sent: $response');

      final message = GroupChatMessage.fromJson(response);
      print('GroupChatRepository: Message created successfully');
      return message;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  /// Update a message (only content can be updated)
  Future<GroupChatMessage> updateMessage({
    required String messageId,
    required String contentText,
  }) async {
    try {
      print('GroupChatRepository: Updating message: $messageId');

      final response = await _supabase
          .from(tableName)
          .update({'content_text': contentText})
          .eq('id', messageId)
          .select()
          .single();

      print('GroupChatRepository: Message updated');
      return GroupChatMessage.fromJson(response);
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to update message: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to update message: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      print('GroupChatRepository: Deleting message: $messageId');

      await _supabase.from(tableName).delete().eq('id', messageId);

      print('GroupChatRepository: Message deleted successfully');
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to delete message: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Get a single message by ID
  Future<GroupChatMessage?> getMessage(String messageId) async {
    try {
      print('GroupChatRepository: Getting message: $messageId');

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', messageId)
          .maybeSingle();

      if (response == null) {
        print('GroupChatRepository: Message not found');
        return null;
      }

      final message = GroupChatMessage.fromJson(response);
      print('GroupChatRepository: Message found');
      return message;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to get message: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to get message: $e');
    }
  }

  /// Get messages with pagination
  Future<List<GroupChatMessage>> getMessagesWithPagination({
    required String courseId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      print(
        'GroupChatRepository: Loading messages with pagination for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      print(
        'GroupChatRepository: Paginated response: ${response.length} messages',
      );

      final List<GroupChatMessage> messages = (response as List)
          .map((json) => GroupChatMessage.fromJson(json))
          .toList();

      return messages;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to load messages: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to load messages: $e');
    }
  }

  /// Get recent messages (last N messages)
  Future<List<GroupChatMessage>> getRecentMessages({
    required String courseId,
    int limit = 100,
  }) async {
    try {
      print(
        'GroupChatRepository: Loading recent messages for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false)
          .limit(limit);

      print(
        'GroupChatRepository: Recent messages response: ${response.length} messages',
      );

      final List<GroupChatMessage> messages = (response as List)
          .map((json) => GroupChatMessage.fromJson(json))
          .toList();

      // Reverse to get chronological order (oldest first)
      return messages.reversed.toList();
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to load recent messages: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to load recent messages: $e');
    }
  }

  /// Search messages by content
  Future<List<GroupChatMessage>> searchMessages({
    required String courseId,
    required String query,
  }) async {
    try {
      print('GroupChatRepository: Searching messages for: $query');

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .textSearch('content_text', query)
          .order('created_at', ascending: true);

      final List<GroupChatMessage> messages = (response as List)
          .map((json) => GroupChatMessage.fromJson(json))
          .toList();

      print('GroupChatRepository: Found ${messages.length} matching messages');
      return messages;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to search messages: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Get messages from a specific sender
  Future<List<GroupChatMessage>> getMessagesBySender({
    required String courseId,
    required String senderId,
  }) async {
    try {
      print('GroupChatRepository: Loading messages from sender: $senderId');

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .eq('sender_id', senderId)
          .order('created_at', ascending: true);

      final List<GroupChatMessage> messages = (response as List)
          .map((json) => GroupChatMessage.fromJson(json))
          .toList();

      print(
        'GroupChatRepository: Found ${messages.length} messages from sender',
      );
      return messages;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to load messages by sender: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to load messages by sender: $e');
    }
  }

  /// Get replies to a specific message
  Future<List<GroupChatMessage>> getReplies(String parentMessageId) async {
    try {
      print(
        'GroupChatRepository: Loading replies for message: $parentMessageId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('parent_message_id', parentMessageId)
          .order('created_at', ascending: true);

      final List<GroupChatMessage> replies = (response as List)
          .map((json) => GroupChatMessage.fromJson(json))
          .toList();

      print('GroupChatRepository: Found ${replies.length} replies');
      return replies;
    } on PostgrestException catch (e) {
      print('GroupChatRepository: Database error: ${e.message}');
      throw Exception('Failed to load replies: ${e.message}');
    } catch (e) {
      print('GroupChatRepository: Unexpected error: $e');
      throw Exception('Failed to load replies: $e');
    }
  }

  /// Subscribe to real-time messages for a course
  RealtimeChannel subscribeToMessages({
    required String courseId,
    required Function(GroupChatMessage) onMessageReceived,
    required Function(GroupChatMessage) onMessageUpdated,
    required Function(String) onMessageDeleted,
  }) {
    print(
      'GroupChatRepository: Setting up real-time subscription for course: $courseId',
    );

    final channel = _supabase
        .channel('group_chat_$courseId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'course_id',
            value: courseId,
          ),
          callback: (payload) {
            print(
              'GroupChatRepository: New message received: ${payload.newRecord}',
            );
            final message = GroupChatMessage.fromJson(payload.newRecord);
            onMessageReceived(message);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'course_id',
            value: courseId,
          ),
          callback: (payload) {
            print('GroupChatRepository: Message updated: ${payload.newRecord}');
            final message = GroupChatMessage.fromJson(payload.newRecord);
            onMessageUpdated(message);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'course_id',
            value: courseId,
          ),
          callback: (payload) {
            print('GroupChatRepository: Message deleted: ${payload.oldRecord}');
            final messageId = payload.oldRecord['id'].toString();
            onMessageDeleted(messageId);
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from real-time messages
  Future<void> unsubscribeFromMessages(RealtimeChannel channel) async {
    print('GroupChatRepository: Unsubscribing from real-time messages');
    await _supabase.removeChannel(channel);
  }
}
