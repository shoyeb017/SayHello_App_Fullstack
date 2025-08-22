/// GroupChat Provider - State management for group chat
/// Handles loading, sending, and managing chat messages with real-time updates

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_chat_message.dart';
import '../data/group_chat_data.dart';

class GroupChatProvider with ChangeNotifier {
  final GroupChatRepository _groupChatRepository = GroupChatRepository();

  List<GroupChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  RealtimeChannel? _realtimeChannel;

  // Getters
  List<GroupChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;

  /// Load messages for a specific course
  Future<void> loadMessages(String courseId) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      print('GroupChatProvider: Loading messages for course: $courseId');

      final messages = await _groupChatRepository.getRecentMessages(
        courseId: courseId,
        limit: 100,
      );

      _messages = messages;
      print('GroupChatProvider: Loaded ${messages.length} messages');

      notifyListeners();
    } catch (e) {
      print('GroupChatProvider: Error loading messages: $e');
      _setError('Failed to load messages: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Send a new message
  Future<bool> sendMessage({
    required String courseId,
    required String senderId,
    required String senderType,
    required String contentText,
    String? parentMessageId,
  }) async {
    if (_isSending || contentText.trim().isEmpty) return false;

    _setSending(true);
    _setError(null);

    try {
      print('GroupChatProvider: Sending message...');

      final message = await _groupChatRepository.sendMessage(
        courseId: courseId,
        senderId: senderId,
        senderType: senderType,
        contentText: contentText.trim(),
        parentMessageId: parentMessageId,
      );

      // Add the message to local list (real-time will also add it, but this provides immediate feedback)
      _messages.add(message);
      print('GroupChatProvider: Message sent successfully');

      notifyListeners();
      return true;
    } catch (e) {
      print('GroupChatProvider: Error sending message: $e');
      _setError('Failed to send message: ${e.toString()}');
      return false;
    } finally {
      _setSending(false);
    }
  }

  /// Update an existing message
  Future<bool> updateMessage({
    required String messageId,
    required String contentText,
  }) async {
    try {
      print('GroupChatProvider: Updating message: $messageId');

      final updatedMessage = await _groupChatRepository.updateMessage(
        messageId: messageId,
        contentText: contentText,
      );

      // Update local message
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }

      print('GroupChatProvider: Message updated successfully');
      return true;
    } catch (e) {
      print('GroupChatProvider: Error updating message: $e');
      _setError('Failed to update message: ${e.toString()}');
      return false;
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      print('GroupChatProvider: Deleting message: $messageId');

      await _groupChatRepository.deleteMessage(messageId);

      // Remove from local list
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();

      print('GroupChatProvider: Message deleted successfully');
      return true;
    } catch (e) {
      print('GroupChatProvider: Error deleting message: $e');
      _setError('Failed to delete message: ${e.toString()}');
      return false;
    }
  }

  /// Search messages
  Future<List<GroupChatMessage>> searchMessages({
    required String courseId,
    required String query,
  }) async {
    try {
      print('GroupChatProvider: Searching messages for: $query');

      final results = await _groupChatRepository.searchMessages(
        courseId: courseId,
        query: query,
      );

      print('GroupChatProvider: Found ${results.length} matching messages');
      return results;
    } catch (e) {
      print('GroupChatProvider: Error searching messages: $e');
      _setError('Failed to search messages: ${e.toString()}');
      return [];
    }
  }

  /// Get messages by sender
  Future<List<GroupChatMessage>> getMessagesBySender({
    required String courseId,
    required String senderId,
  }) async {
    try {
      return await _groupChatRepository.getMessagesBySender(
        courseId: courseId,
        senderId: senderId,
      );
    } catch (e) {
      print('GroupChatProvider: Error getting messages by sender: $e');
      return [];
    }
  }

  /// Get replies to a message
  Future<List<GroupChatMessage>> getReplies(String parentMessageId) async {
    try {
      return await _groupChatRepository.getReplies(parentMessageId);
    } catch (e) {
      print('GroupChatProvider: Error getting replies: $e');
      return [];
    }
  }

  /// Subscribe to real-time updates
  void subscribeToRealTimeUpdates(String courseId) {
    if (_realtimeChannel != null) {
      unsubscribeFromRealTimeUpdates();
    }

    print(
      'GroupChatProvider: Subscribing to real-time updates for course: $courseId',
    );

    _realtimeChannel = _groupChatRepository.subscribeToMessages(
      courseId: courseId,
      onMessageReceived: (message) {
        print('GroupChatProvider: Real-time message received: ${message.id}');

        // Check if message already exists (to avoid duplicates)
        if (!_messages.any((m) => m.id == message.id)) {
          _messages.add(message);
          notifyListeners();
        }
      },
      onMessageUpdated: (message) {
        print('GroupChatProvider: Real-time message updated: ${message.id}');

        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = message;
          notifyListeners();
        }
      },
      onMessageDeleted: (messageId) {
        print('GroupChatProvider: Real-time message deleted: $messageId');

        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
      },
    );
  }

  /// Unsubscribe from real-time updates
  void unsubscribeFromRealTimeUpdates() {
    if (_realtimeChannel != null) {
      print('GroupChatProvider: Unsubscribing from real-time updates');
      _groupChatRepository.unsubscribeFromMessages(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  /// Clear all messages
  void clearMessages() {
    print('GroupChatProvider: Clearing all messages');
    _messages.clear();
    notifyListeners();
  }

  /// Refresh messages (reload from server)
  Future<void> refreshMessages(String courseId) async {
    print('GroupChatProvider: Refreshing messages...');
    await loadMessages(courseId);
  }

  /// Get messages by type (instructor/learner)
  List<GroupChatMessage> getMessagesByType(String senderType) {
    return _messages.where((m) => m.senderType == senderType).toList();
  }

  /// Get instructor messages
  List<GroupChatMessage> get instructorMessages {
    return getMessagesByType('instructor');
  }

  /// Get learner messages
  List<GroupChatMessage> get learnerMessages {
    return getMessagesByType('learner');
  }

  /// Get latest message
  GroupChatMessage? get latestMessage {
    if (_messages.isEmpty) return null;
    return _messages.last;
  }

  /// Get message count
  int get messageCount => _messages.length;

  /// Check if user has sent any messages
  bool hasUserSentMessages(String userId) {
    return _messages.any((m) => m.senderId == userId);
  }

  /// Get messages in proper linked-list order using parent_message_id
  /// TODO: Implement this when full threading is needed
  List<GroupChatMessage> getMessagesInThreadOrder() {
    // For now, return chronological order
    // In future, implement proper linked-list traversal using parent_message_id
    return _messages;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSending(bool sending) {
    _isSending = sending;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    unsubscribeFromRealTimeUpdates();
    super.dispose();
  }
}
