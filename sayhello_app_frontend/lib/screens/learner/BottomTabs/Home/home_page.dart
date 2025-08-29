import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/models.dart';
import '../../../../data/learner_data.dart';
import 'translator_in_home.dart';
import '../../Chat/chat.dart'; // Import the fixed chat interface
import '../../Notifications/notifications.dart';
import 'package:sayhello_app_frontend/providers/settings_provider.dart';

void main() {
  runApp(const LanguageTalksApp());
}

class LanguageTalksApp extends StatelessWidget {
  const LanguageTalksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Dummy data models (for categories)
class Category {
  final IconData icon;
  final String label;
  final Color background;

  const Category(this.icon, this.label, this.background);
}

// ──────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final LearnerRepository _learnerRepository = LearnerRepository();
  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, Learner> _userCache = {}; // Cache for loaded users
  ChatProvider? _chatProvider; // Store reference for real-time subscription
  Timer? _searchDebouncer; // Debouncer for search
  Timer? _periodicRefreshTimer; // Timer for periodic refresh

  @override
  void initState() {
    super.initState();

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserChats();
    });

    // Add listener to search controller for real-time search
    _searchController.addListener(_onSearchChanged);

    // Set up minimal periodic refresh as fallback only (reduced frequency since real-time is primary)
    _periodicRefreshTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) {
      if (mounted) {
        print('HomePage: Fallback periodic refresh triggered');
        _loadUserChats();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // App came to foreground, refresh chat list
      print('HomePage: App resumed, refreshing chat list');
      _loadUserChats();
    }
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchDebouncer?.cancel();

    // Create new timer for debounced search
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store reference to ChatProvider for use in dispose()
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Set up real-time subscription for chat list with instant updates
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null &&
        authProvider.currentUser is Learner) {
      final currentUser = authProvider.currentUser as Learner;
      _chatProvider?.subscribeToUserChatList(currentUser.id);

      // Add listener for instant real-time chat updates
      _chatProvider?.addListener(_onChatProviderUpdate);

      // Immediately load initial data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserChats();
      });
    }
  }

  /// Handle real-time updates from ChatProvider
  void _onChatProviderUpdate() {
    if (mounted) {
      print('HomePage: ChatProvider updated, refreshing UI...');
      setState(() {
        // Trigger rebuild to show latest chat data
      });
      // Preload user data for new chats
      _preloadUserDataInstant();
    }
  }

  // Preload user data for better performance - instant version
  void _preloadUserDataInstant() async {
    if (!mounted) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUserId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser?.id;

    if (currentUserId == null) return;

    // Use existing userChats property and preload method for consistency
    _preloadChatUsers(chatProvider.userChats, currentUserId);
  }

  /// Build skeleton loading for better perceived performance
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Avatar skeleton
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 15),
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              // Time skeleton
              Container(
                height: 12,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Remove ChatProvider listener
    _chatProvider?.removeListener(_onChatProviderUpdate);

    // Unsubscribe from real-time chat list updates using stored reference
    _chatProvider?.unsubscribeFromUserChatList();

    // Clean up timers
    _searchDebouncer?.cancel();
    _periodicRefreshTimer?.cancel();

    // Remove listener and dispose controllers
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserChats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser != null &&
        authProvider.currentUser is Learner) {
      final currentUser = authProvider.currentUser as Learner;

      print('HomePage: Loading user chats for ${currentUser.id}');

      try {
        // Load chats with faster timeout and better error handling
        await chatProvider.loadUserChats(currentUser.id);

        // Preload user data for better search performance (async, non-blocking)
        _preloadChatUsers(chatProvider.userChats, currentUser.id);
      } catch (e) {
        print('HomePage: Error loading chats: $e');
        // Don't block UI for failed loads, show cached data if available
      }
    }
  }

  /// Refresh chat list - called when returning from individual chat
  Future<void> _refreshChatList() async {
    print('HomePage: Refreshing chat list...');
    await _loadUserChats();
  }

  /// Preload user data for all chat partners to improve search performance
  void _preloadChatUsers(
    List<ChatWithLatestMessage> chats,
    String currentUserId,
  ) {
    for (final chatWithMessage in chats) {
      final otherUserId = chatWithMessage.chat.user1Id == currentUserId
          ? chatWithMessage.chat.user2Id
          : chatWithMessage.chat.user1Id;

      // Skip if already cached
      if (!_userCache.containsKey(otherUserId)) {
        _learnerRepository
            .getLearnerById(otherUserId)
            .then((learner) {
              if (learner != null && mounted) {
                setState(() {
                  _userCache[otherUserId] = learner;
                });
              }
            })
            .catchError((error) {
              print('Error preloading user $otherUserId: $error');
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              // SETTINGS ICON - This is the settings button in the app bar
              // Click this to open the settings bottom sheet with theme and language options
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () =>
                    SettingsProvider.showSettingsBottomSheet(context),
              ),

              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.home,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),

              // 🔔 NOTIFICATION ICON - This is the notification button in the app bar
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  // Red dot for unread notifications
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '3', // Number of unread notifications
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // Horizontal categories
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                // Translate option
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TranslatorInHome(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.translate,
                          size: 26,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 72,
                        child: Text(
                          AppLocalizations.of(context)!.translate,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Color Mode option
                GestureDetector(
                  onTap: () {
                    bool toDark = themeProvider.themeMode != ThemeMode.dark;
                    themeProvider.toggleTheme(toDark);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A54FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          size: 26,
                          color: const Color(0xFF7A54FF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 72,
                        child: Text(
                          AppLocalizations.of(context)!.colorMode,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Language Settings option
                GestureDetector(
                  onTap: () {
                    SettingsProvider.showLanguageSelector(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.language,
                          size: 26,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 72,
                        child: Text(
                          AppLocalizations.of(context)!.language,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search bar for chats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: _isSearching
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            hintText: AppLocalizations.of(
                              context,
                            )!.searchPeople,
                            hintStyle: const TextStyle(fontSize: 16),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ],
                  )
                : InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.seePeoplesChats,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // const Divider(height: 1),

          // Chat list with optimized loading
          Expanded(
            child: Consumer2<ChatProvider, AuthProvider>(
              builder: (context, chatProvider, authProvider, child) {
                // Show skeleton loading only on initial load, not on updates
                if (chatProvider.isLoading && chatProvider.userChats.isEmpty) {
                  return _buildSkeletonLoading();
                }

                if (chatProvider.hasError && chatProvider.userChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load chats',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadUserChats,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter chats based on search query
                final allChats = chatProvider.userChats;
                final currentUserId = authProvider.currentUser?.id ?? '';

                // Sort chats by latest message time (newest first)
                final sortedChats = List<ChatWithLatestMessage>.from(allChats)
                  ..sort((a, b) {
                    final aTime =
                        a.latestMessage?.createdAt ?? a.chat.createdAt;
                    final bTime =
                        b.latestMessage?.createdAt ?? b.chat.createdAt;
                    return bTime.compareTo(aTime); // Newest first
                  });

                List<ChatWithLatestMessage> filteredChats;
                if (_searchQuery.isEmpty) {
                  filteredChats = sortedChats;
                } else {
                  // Create a list to store filtered chats
                  filteredChats = [];

                  for (final chatWithMessage in sortedChats) {
                    final otherUserId =
                        chatWithMessage.chat.user1Id == currentUserId
                        ? chatWithMessage.chat.user2Id
                        : chatWithMessage.chat.user1Id;

                    // Check if user is already cached
                    final cachedUser = _userCache[otherUserId];
                    if (cachedUser != null) {
                      // Search in cached user data
                      final searchTerm = _searchQuery.toLowerCase();
                      if (cachedUser.name.toLowerCase().contains(searchTerm) ||
                          cachedUser.username.toLowerCase().contains(
                            searchTerm,
                          ) ||
                          (cachedUser.bio?.toLowerCase().contains(searchTerm) ??
                              false)) {
                        filteredChats.add(chatWithMessage);
                      }
                    } else {
                      // If user is not cached, load them asynchronously and add to filtered list
                      filteredChats.add(chatWithMessage);

                      // Load user data in background for future searches
                      _learnerRepository
                          .getLearnerById(otherUserId)
                          .then((learner) {
                            if (learner != null && mounted) {
                              setState(() {
                                _userCache[otherUserId] = learner;
                              });
                            }
                          })
                          .catchError((error) {
                            print(
                              'Error loading user $otherUserId for search: $error',
                            );
                          });
                    }
                  }
                }

                if (filteredChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No chats yet'
                              : 'No chats found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with someone!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    print('HomePage: Pull-to-refresh triggered');
                    await _loadUserChats();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chatWithMessage = filteredChats[index];
                      return Column(
                        children: [
                          _BackendChatTile(
                            chatWithMessage: chatWithMessage,
                            currentUserId: authProvider.currentUser?.id ?? '',
                            learnerRepository: _learnerRepository,
                            userCache: _userCache,
                            onChatOpened:
                                _refreshChatList, // Pass refresh callback
                          ),
                          // Partial width divider with indent and endIndent
                          if (index != filteredChats.length - 1)
                            Divider(
                              indent: 90, // same as avatar + padding approx
                              endIndent: 20, // to stop short of right edge
                              height: 1,
                              thickness: 0.7,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade400,
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category pill widget
// class _CategoryTile extends StatelessWidget {
//   final Category category;
//   const _CategoryTile({required this.category});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: category.background.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Icon(category.icon, size: 26, color: category.background),
//         ),
//         const SizedBox(height: 4),
//         SizedBox(
//           width: 72,
//           child: Text(
//             category.label,
//             textAlign: TextAlign.center,
//             style: Theme.of(
//               context,
//             ).textTheme.bodySmall?.copyWith(fontSize: 11),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }

// ──────────────────────────────────────────────────────────────────────────────
// Backend Chat Tile - uses real chat data from ChatProvider
class _BackendChatTile extends StatefulWidget {
  final ChatWithLatestMessage chatWithMessage;
  final String currentUserId;
  final LearnerRepository learnerRepository;
  final Map<String, Learner> userCache;
  final VoidCallback? onChatOpened; // Callback to refresh parent

  const _BackendChatTile({
    required this.chatWithMessage,
    required this.currentUserId,
    required this.learnerRepository,
    required this.userCache,
    this.onChatOpened,
  });

  @override
  State<_BackendChatTile> createState() => _BackendChatTileState();
}

class _BackendChatTileState extends State<_BackendChatTile> {
  Learner? _otherUser;
  bool _isLoading = false; // Start with false to show content immediately

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  void _loadOtherUser() async {
    try {
      // Get the other user's ID (not the current user)
      final otherUserId =
          widget.chatWithMessage.chat.user1Id == widget.currentUserId
          ? widget.chatWithMessage.chat.user2Id
          : widget.chatWithMessage.chat.user1Id;

      // Check cache first - if available, show immediately
      if (widget.userCache.containsKey(otherUserId)) {
        if (mounted) {
          setState(() {
            _otherUser = widget.userCache[otherUserId];
            _isLoading = false;
          });
        }
        return;
      }

      // If not cached, show loading state briefly
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // Load user data with timeout for better performance
      final learner = await widget.learnerRepository
          .getLearnerById(otherUserId)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('HomePage: Timeout loading user $otherUserId');
              return null;
            },
          );

      if (mounted) {
        setState(() {
          _otherUser = learner;
          _isLoading = false;
        });

        // Cache the user for future use and search functionality
        if (learner != null) {
          widget.userCache[otherUserId] = learner;
        }
      }
    } catch (e) {
      print('Error loading other user: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      // Older - show date
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Instant display with cached data or placeholder
    final hasUnread = widget.chatWithMessage.hasUnread;
    final latestMessage = widget.chatWithMessage.latestMessage;
    final otherUserName = _otherUser?.name ?? 'Loading...';
    final otherUserAvatar = _otherUser?.profileImage;

    String lastMessageText = 'No messages yet';
    String dateLabel = '';

    if (latestMessage != null) {
      lastMessageText = latestMessage.type == 'image'
          ? '📎 Image'
          : (latestMessage.contentText ?? 'Message');
      dateLabel = _formatDate(latestMessage.createdAt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Container(
        decoration: hasUnread
            ? BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                border: Border(
                  left: BorderSide(color: theme.primaryColor, width: 3),
                ),
              )
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: otherUserAvatar != null
                    ? NetworkImage(otherUserAvatar)
                    : null,
                backgroundColor: Colors.grey[300],
                child: otherUserAvatar == null
                    ? Icon(
                        _isLoading ? Icons.person : Icons.person,
                        color: _isLoading ? Colors.grey[400] : Colors.white,
                        size: 32,
                      )
                    : null,
              ),
              // Online indicator (can be enhanced with real status)
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green, // Real-time online status
                    border: Border.all(color: Colors.white, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            otherUserName,
            style: TextStyle(
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
              fontSize: hasUnread ? 16 : 15,
              color: _isLoading ? Colors.grey[400] : null,
            ),
          ),
          subtitle: Text(
            lastMessageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasUnread
                  ? (theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87)
                  : (theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600]),
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              fontSize: hasUnread ? 14 : 13,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: hasUnread
                      ? theme.primaryColor
                      : (theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600]),
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (hasUnread)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.chatWithMessage.unreadCount > 99
                        ? '99+'
                        : widget.chatWithMessage.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          onTap: () async {
            if (_otherUser != null) {
              // Create a ChatUser from the Learner data to navigate to individual chat
              final chatUser = ChatUser(
                id: _otherUser!.id,
                name: _otherUser!.name,
                avatarUrl: _otherUser!.profileImage ?? '',
                country: _otherUser!.country,
                flag: _getCountryFlag(_otherUser!.country),
                age: _calculateAge(_otherUser!.dateOfBirth),
                gender: _otherUser!.gender == 'male' ? 'M' : 'F',
                isOnline: true, // Could be enhanced with real online status
                lastSeen:
                    DateTime.now(), // Could be enhanced with real last seen
                interests: _otherUser!.interests,
                nativeLanguage: _otherUser!.nativeLanguage,
                learningLanguage: _otherUser!.learningLanguage,
              );

              // Navigate to chat with instant transition
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailPage(user: chatUser),
                ),
              );

              // Instant callback for immediate parent refresh regardless of result
              if (context.mounted && widget.onChatOpened != null) {
                print('ChatTile: Triggering instant parent refresh...');
                widget.onChatOpened!();
              }

              // Additional instant state update if chat was modified
              if (result == true && mounted) {
                setState(() {
                  // Force rebuild to show latest changes immediately
                });
              }
            }
          },
        ),
      ),
    );
  }

  String _getCountryFlag(String country) {
    switch (country.toLowerCase()) {
      case 'usa':
        return '🇺🇸';
      case 'spain':
        return '🇪🇸';
      case 'japan':
        return '🇯🇵';
      case 'korea':
        return '🇰🇷';
      case 'bangladesh':
        return '🇧🇩';
      default:
        return '🌍';
    }
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
