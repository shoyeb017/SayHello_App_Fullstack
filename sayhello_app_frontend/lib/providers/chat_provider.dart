/// Chat Provider - State management for chat and messaging operations
/// Handles chat rooms, messages, and real-time messaging functionality

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../data/data.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  // Chat state
  List<ChatWithLatestMessage> _userChats = [];
  Chat? _currentChat;
  List<ChatMessage> _messages = [];
  Map<String, int> _unreadCounts = {};

  // Real-time subscriptions
  RealtimeChannel? _messagesSubscription;
  RealtimeChannel? _chatsSubscription;

  // Loading states
  bool _isLoading = false;
  bool _isMessagesLoading = false;
  bool _isSending = false;

  // Context tracking
  bool _isViewingHomePage = false; // Track if user is on home page

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

      // Subscribe to real-time chat updates
      _subscribeToChats(userId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load messages for current chat
  Future<void> _loadChatMessages(String chatId, {int limit = 100}) async {
    _isMessagesLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _messages = await _repository.getChatMessages(chatId, limit: limit);
    } catch (e) {
      _setError('Failed to load messages: $e');
    } finally {
      _isMessagesLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages({int limit = 50}) async {
    if (_currentChat == null || _isMessagesLoading) return;

    _isMessagesLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final olderMessages = await _repository.getChatMessages(
        _currentChat!.id,
        limit: limit,
        offset: _messages.length,
      );

      // Add older messages to the beginning of the list
      _messages.insertAll(0, olderMessages);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load more messages: $e');
    } finally {
      _isMessagesLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // =============================
  // MESSAGE OPERATIONS
  // =============================

  /// Send a message
  Future<bool> sendMessage(
    String messageText, {
    String? imageUrl,
    String messageType = 'text',
    String? parentMsgId,
    String senderId = '',
  }) async {
    if (_currentChat == null || messageText.trim().isEmpty) return false;

    _isSending = true;
    _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final chatMessage = ChatMessage(
        id: '', // Will be generated
        chatId: _currentChat!.id,
        senderId: senderId, // Should be set from current user
        contentText: messageType == 'text' ? messageText.trim() : imageUrl,
        type: messageType,
        status: 'unread',
        parentMsgId: parentMsgId,
        createdAt: DateTime.now(),
      );

      final sentMessage = await _repository.sendMessage(chatMessage);

      // Add message to local list
      _messages.add(sentMessage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Also trigger a refresh of user chats to update the chat list with latest message
      // This ensures the home page chat list shows the new message immediately
      _refreshUserChatsIfNeeded(senderId);

      return true;
    } catch (e) {
      _setError('Failed to send message: $e');
      return false;
    } finally {
      _isSending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
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
        if (_messages[i].senderId != userId &&
            _messages[i].status == 'unread') {
          _messages[i] = _messages[i].markAsRead();
        }
      }

      // Update unread count
      _unreadCounts[_currentChat!.id] = 0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
    try {
      return _userChats.firstWhere((chat) => chat.chat.isParticipant(userId));
    } catch (e) {
      return null; // Return null if not found
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Add message to current chat (for real-time updates)
  void addMessage(ChatMessage message) {
    if (_currentChat?.id == message.chatId) {
      _messages.add(message);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Unsubscribe from real-time channels
    _messagesSubscription?.unsubscribe();
    _chatsSubscription?.unsubscribe();
    clear();
    super.dispose();
  }

  // =============================
  // REAL-TIME SUBSCRIPTIONS
  // =============================

  /// Public method to subscribe to real-time updates (called from UI)
  void subscribeToRealTimeUpdates(String chatId) {
    print(
      'ChatProvider: Public method - subscribing to real-time updates for chat: $chatId',
    );
    _isViewingHomePage =
        false; // Mark that user is viewing individual chat, not home page
    _subscribeToMessages(chatId);
  }

  /// Public method to unsubscribe from real-time updates
  void unsubscribeFromRealTimeUpdates() {
    print('ChatProvider: Unsubscribing from real-time updates');
    // Don't set _isViewingHomePage here as user might be going back to home
    _messagesSubscription?.unsubscribe();
    _chatsSubscription?.unsubscribe();
    _messagesSubscription = null;
    _chatsSubscription = null;
  }

  /// Subscribe to real-time message updates for current chat
  void _subscribeToMessages(String chatId) {
    // Unsubscribe from previous subscription if any
    _messagesSubscription?.unsubscribe();

    print('ChatProvider: Subscribing to real-time messages for chat: $chatId');

    _messagesSubscription = _repository.subscribeToMessages(
      chatId: chatId,
      onMessageReceived: (message) {
        print('ChatProvider: New message received: ${message.contentText}');

        // Add to messages if not already present
        if (!_messages.any((msg) => msg.id == message.id)) {
          _messages.add(message);
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      },
      onMessageUpdated: (message) {
        print('ChatProvider: Message updated: ${message.id}');

        // Find and update existing message
        final index = _messages.indexWhere((msg) => msg.id == message.id);
        if (index != -1) {
          _messages[index] = message;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      },
    );
  }

  /// Subscribe to real-time chat updates for user
  void _subscribeToChats(String userId) {
    // Unsubscribe from previous subscription if any
    _chatsSubscription?.unsubscribe();

    print('ChatProvider: Subscribing to real-time chats for user: $userId');

    _chatsSubscription = _repository.subscribeToUserChats(
      userId: userId,
      onChatAdded: (chat) {
        print('ChatProvider: New chat added: ${chat.id}');
        // Could reload user chats here if needed
      },
    );
  }

  /// Public method to subscribe to chat list real-time updates (for home page)
  void subscribeToUserChatList(String userId) {
    print(
      'ChatProvider: Public method - subscribing to chat list updates for user: $userId',
    );
    _isViewingHomePage = true; // Mark that user is viewing home page
    _subscribeToChatsForList(userId);
  }

  /// Public method to unsubscribe from chat list real-time updates
  void unsubscribeFromUserChatList() {
    print('ChatProvider: Unsubscribing from chat list updates');
    _isViewingHomePage = false; // Mark that user is no longer viewing home page
    _chatsSubscription?.unsubscribe();
    _chatsSubscription = null;
  }

  /// Mark that user has returned to home page (call this when navigating back to home)
  void markReturnedToHomePage() {
    print('ChatProvider: User returned to home page');
    _isViewingHomePage = true;
  }

  /// Subscribe to real-time message updates that affect chat list
  void _subscribeToChatsForList(String userId) {
    // Unsubscribe from previous subscription if any
    _chatsSubscription?.unsubscribe();

    print(
      'ChatProvider: Subscribing to real-time messages for chat list, user: $userId',
    );

    _chatsSubscription = _repository.subscribeToMessagesForChatList(
      userId: userId,
      onNewMessage: (message) {
        print(
          'ChatProvider: New message received for chat list: ${message.contentText}',
        );

        // Reload user chats to get updated latest message and unread counts
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await loadUserChats(userId);
        });
      },
      onMessageUpdated: (message) {
        print('ChatProvider: Message updated for chat list: ${message.id}');

        // Reload user chats to get updated message status
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await loadUserChats(userId);
        });
      },
    );
  }

  /// Refresh user chats if they are loaded (to update chat list with latest messages)
  void _refreshUserChatsIfNeeded(String userId) {
    // Only refresh if we have user chats loaded AND user is currently viewing the home page
    if (_userChats.isNotEmpty && _isViewingHomePage) {
      print(
        'ChatProvider: Refreshing user chats after sending message (user is on home page)',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await loadUserChats(userId);
        } catch (e) {
          print('ChatProvider: Error refreshing user chats: $e');
        }
      });
    } else {
      print(
        'ChatProvider: Not refreshing user chats - user is not on home page or no chats loaded',
      );
    }
  }
}
