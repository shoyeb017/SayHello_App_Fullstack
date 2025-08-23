import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/models.dart';
import '../../../../data/learner_data.dart';
import 'translator_in_home.dart';
import '../../Chat/chat.dart'; // Import our new chat interface
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

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final LearnerRepository _learnerRepository = LearnerRepository();
  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, Learner> _userCache = {}; // Cache for loaded users

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserChats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.currentUser != null && authProvider.currentUser is Learner) {
      final currentUser = authProvider.currentUser as Learner;
      await chatProvider.loadUserChats(currentUser.id);
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
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
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

          // Chat list
          Expanded(
            child: Consumer2<ChatProvider, AuthProvider>(
              builder: (context, chatProvider, authProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (chatProvider.hasError) {
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
                
                List<ChatWithLatestMessage> filteredChats;
                if (_searchQuery.isEmpty) {
                  filteredChats = allChats;
                } else {
                  filteredChats = allChats.where((chatWithMessage) {
                    final otherUserId = chatWithMessage.chat.user1Id == currentUserId
                        ? chatWithMessage.chat.user2Id
                        : chatWithMessage.chat.user1Id;
                    
                    final cachedUser = _userCache[otherUserId];
                    if (cachedUser != null) {
                      return cachedUser.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             cachedUser.username.toLowerCase().contains(_searchQuery.toLowerCase());
                    }
                    return false; // Don't show chats for users we haven't loaded yet
                  }).toList();
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
                  onRefresh: _loadUserChats,
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
                          ),
                          // Partial width divider with indent and endIndent
                          if (index != filteredChats.length - 1)
                            Divider(
                              indent: 90, // same as avatar + padding approx
                              endIndent: 20, // to stop short of right edge
                              height: 1,
                              thickness: 0.7,
                              color:
                                  Theme.of(context).brightness == Brightness.dark
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

  const _BackendChatTile({
    required this.chatWithMessage,
    required this.currentUserId,
    required this.learnerRepository,
    required this.userCache,
  });

  @override
  State<_BackendChatTile> createState() => _BackendChatTileState();
}

class _BackendChatTileState extends State<_BackendChatTile> {
  Learner? _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  void _loadOtherUser() async {
    try {
      // Get the other user's ID (not the current user)
      final otherUserId = widget.chatWithMessage.chat.user1Id == widget.currentUserId
          ? widget.chatWithMessage.chat.user2Id
          : widget.chatWithMessage.chat.user1Id;

      // Check cache first
      if (widget.userCache.containsKey(otherUserId)) {
        setState(() {
          _otherUser = widget.userCache[otherUserId];
          _isLoading = false;
        });
        return;
      }

      final learner = await widget.learnerRepository.getLearnerById(otherUserId);
      
      if (mounted) {
        setState(() {
          _otherUser = learner;
          _isLoading = false;
        });
        
        // Cache the user for future use
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

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final hasUnread = widget.chatWithMessage.hasUnread;
    final latestMessage = widget.chatWithMessage.latestMessage;
    final otherUserName = _otherUser?.name ?? 'Unknown User';
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
                  ? const Icon(Icons.person, color: Colors.white, size: 32)
                  : null,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  border: Border.all(color: Colors.white, width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          otherUserName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          lastMessageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasUnread ? theme.primaryColor : null,
            fontWeight: hasUnread ? FontWeight.w500 : null,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(dateLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            if (hasUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF311b86)
                      : const Color(0xFFefecfd),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.chatWithMessage.unreadCount.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF765ae3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
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
              lastSeen: DateTime.now(), // Could be enhanced with real last seen
              interests: _otherUser!.interests,
              nativeLanguage: _otherUser!.nativeLanguage,
              learningLanguage: _otherUser!.learningLanguage,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(user: chatUser),
              ),
            );
          }
        },
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
