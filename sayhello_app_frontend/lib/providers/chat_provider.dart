/// Chat Provider - State management for chat and messaging operations
/// Handles chat rooms, messages, and real-time messaging functionality

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  // Chat state
  List<ChatWithLatestMessage> _userChats = [];
  Chat? _currentChat;
  List<ChatMessage> _messages = [];
  Map<String, int> _unreadCounts = {};

  // Loading states
  bool _isLoading = false;
  bool _isMessagesLoading = false;
  bool _isSending = false;

  // Error state
  String? _error;

  // Getters
  List<ChatWithLatestMessage> get userChats => _userChats;
  Chat? get currentChat => _currentChat;
  List<ChatMessage> get messages => _messages;
  Map<String, int> get unreadCounts => _unreadCounts;
  bool get isLoading => _isLoading;
  bool get isMessagesLoading => _isMessagesLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  bool get hasError => _error != null;

  // Computed properties
  int get totalUnreadCount =>
      _unreadCounts.values.fold(0, (sum, count) => sum + count);

  // =============================
  // CHAT OPERATIONS
  // =============================

  /// Load all chats for a user
  Future<void> loadUserChats(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _userChats = await _repository.getUserChats(userId);

      // Update unread counts
      _unreadCounts.clear();
      for (final chatWithMessage in _userChats) {
        _unreadCounts[chatWithMessage.chat.id] = chatWithMessage.unreadCount;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load user chats: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load or create chat between two users
  Future<void> loadOrCreateChat(String user1Id, String user2Id) async {
    _setLoading(true);
    _clearError();

    try {
      // First try to get existing chat
      Chat? existingChat = await _repository.getChatBetweenUsers(
        user1Id,
        user2Id,
      );

      // If no chat exists, create one
      if (existingChat == null) {
        existingChat = await _repository.createChat(user1Id, user2Id);
      }

      _currentChat = existingChat;

      // Load messages for this chat
      await _loadChatMessages(existingChat.id);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load or create chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set current chat
  Future<void> setCurrentChat(String chatId) async {
    _setLoading(true);
    _clearError();

    try {
      final chat = await _repository.getChatById(chatId);
      _currentChat = chat;

      if (chat != null) {
        await _loadChatMessages(chatId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load messages for current chat
  Future<void> _loadChatMessages(String chatId, {int limit = 100}) async {
    _isMessagesLoading = true;
    notifyListeners();

    try {
      _messages = await _repository.getChatMessages(chatId, limit: limit);
    } catch (e) {
      _setError('Failed to load messages: $e');
    } finally {
      _isMessagesLoading = false;
      notifyListeners();
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages({int limit = 50}) async {
    if (_currentChat == null || _isMessagesLoading) return;

    _isMessagesLoading = true;
    notifyListeners();

    try {
      final olderMessages = await _repository.getChatMessages(
        _currentChat!.id,
        limit: limit,
        offset: _messages.length,
      );

      // Add older messages to the beginning of the list
      _messages.insertAll(0, olderMessages);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load more messages: $e');
    } finally {
      _isMessagesLoading = false;
      notifyListeners();
    }
  }

  // =============================
  // MESSAGE OPERATIONS
  // =============================

  /// Send a message
  Future<bool> sendMessage(
    String message, {
    String? fileUrl,
    String? messageType,
  }) async {
    if (_currentChat == null || message.trim().isEmpty) return false;

    _isSending = true;
    _clearError();
    notifyListeners();

    try {
      final chatMessage = ChatMessage(
        id: '', // Will be generated
        chatId: _currentChat!.id,
        senderId: '', // Should be set from current user
        message: message.trim(),
        createdAt: DateTime.now(),
        messageType: messageType ?? 'text',
        fileUrl: fileUrl,
        isRead: false,
      );

      final sentMessage = await _repository.sendMessage(chatMessage);

      // Add message to local list
      _messages.add(sentMessage);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to send message: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _repository.markMessageAsRead(messageId);

      // Update local message
      final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex] = _messages[messageIndex].markAsRead();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark message as read: $e');
    }
  }

  /// Mark all messages in current chat as read
  Future<void> markChatMessagesAsRead(String userId) async {
    if (_currentChat == null) return;

    try {
      await _repository.markChatMessagesAsRead(_currentChat!.id, userId);

      // Update local messages
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].senderId != userId && !_messages[i].isRead) {
          _messages[i] = _messages[i].markAsRead();
        }
      }

      // Update unread count
      _unreadCounts[_currentChat!.id] = 0;

      notifyListeners();
    } catch (e) {
      _setError('Failed to mark chat messages as read: $e');
    }
  }

  /// Delete message
  Future<bool> deleteMessage(String messageId) async {
    _clearError();

    try {
      await _repository.deleteMessage(messageId);

      // Remove from local list
      _messages.removeWhere((msg) => msg.id == messageId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete message: $e');
      return false;
    }
  }

  /// Delete chat
  Future<bool> deleteChat(String chatId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteChat(chatId);

      // Remove from local list
      _userChats.removeWhere((chat) => chat.chat.id == chatId);
      _unreadCounts.remove(chatId);

      // Clear current chat if it's the same
      if (_currentChat?.id == chatId) {
        _currentChat = null;
        _messages = [];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete chat: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  /// Get chat with another user
  ChatWithLatestMessage? getChatWithUser(String userId) {
    return _userChats.firstWhere(
      (chat) => chat.chat.participantIds.contains(userId),
      orElse: () => _userChats.first, // This will throw if empty
    );
  }

  /// Get unread message count for user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      return await _repository.getUnreadMessageCount(userId);
    } catch (e) {
      _setError('Failed to get unread message count: $e');
      return 0;
    }
  }

  /// Clear current chat
  void clearCurrentChat() {
    _currentChat = null;
    _messages = [];
    notifyListeners();
  }

  /// Add message to current chat (for real-time updates)
  void addMessage(ChatMessage message) {
    if (_currentChat?.id == message.chatId) {
      _messages.add(message);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all data
  void clear() {
    _userChats = [];
    _currentChat = null;
    _messages = [];
    _unreadCounts = {};
    _isLoading = false;
    _isMessagesLoading = false;
    _isSending = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
