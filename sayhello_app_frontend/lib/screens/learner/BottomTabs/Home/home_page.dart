import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';
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
// Dummy data models
class Category {
  final IconData icon;
  final String label;
  final Color background;

  const Category(this.icon, this.label, this.background);
}

class ChatItem {
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String dateLabel;
  final bool myTurn;

  const ChatItem({
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.dateLabel,
    required this.myTurn,
  });
}

// ──────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dummy categories (top pill buttons)
  // static const _categories = <Category>[
  //   Category(Icons.menu_book_outlined, 'All Courses', Color(0xFF1E88E5)),
  //   Category(Icons.play_circle_fill, 'Play', Color(0xFF00C853)),
  //   Category(Icons.translate, 'Translate', Color(0xFF42A5F5)),
  //   Category(Icons.face_4_rounded, 'Japanese Ai', Color(0xFFFF4081)),
  //   Category(Icons.expand_more, 'More', Colors.grey),
  // ];

  // Dummy chat list – replace with real API data later.
  static final _chats = <ChatItem>[
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/a/60',
      name: 'ちょこ',
      lastMessage: 'ちょこ waved at you!',
      dateLabel: '28/06',
      myTurn: true,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/b/60',
      name: 'Airi',
      lastMessage: 'Hello, how are you?',
      dateLabel: '28/06',
      myTurn: true,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/c/60',
      name: 'ょこょこ',
      lastMessage: 'Hi, I am new here!',
      dateLabel: '24/06',
      myTurn: false,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/d/60',
      name: ' Hinata',
      lastMessage: 'You waved at hinata!',
      dateLabel: '19/06',
      myTurn: false,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/e/60',
      name: 'Sasuke',
      lastMessage: 'Heelloo',
      dateLabel: '16/06',
      myTurn: true,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/f/60',
      name: 'ちょこ',
      lastMessage: 'ちょこ waved at you!',
      dateLabel: '28/06',
      myTurn: true,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/g/60',
      name: 'Kim',
      lastMessage: 'Hello, how are you?',
      dateLabel: '28/06',
      myTurn: false,
    ),
    const ChatItem(
      avatarUrl: 'https://picsum.photos/seed/h/60',
      name: 'ょこょこ',
      lastMessage: 'Hi, I am new here!',
      dateLabel: '24/06',
      myTurn: false,
    ),
  ];

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
            child: Builder(
              builder: (context) {
                // Filter chats based on search query
                final filteredChats = _searchQuery.isEmpty
                    ? _chats
                    : _chats
                          .where(
                            (chat) => chat.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return Column(
                      children: [
                        _ChatTile(chat: chat),
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
// Single chat row
class _ChatTile extends StatelessWidget {
  final ChatItem chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 1.5,
      ), // smaller vertical gap
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 32, // slightly bigger avatar
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 14, // a bit bigger to match avatar
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
          chat.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(chat.dateLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            if (chat.myTurn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF311b86)
                      : const Color(0xFFefecfd),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.newMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF765ae3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          // Create a ChatUser from the ChatItem data to navigate to individual chat
          final chatUser = ChatUser(
            id: 'user_${chat.name}',
            name: chat.name,
            avatarUrl: chat.avatarUrl,
            country: 'Unknown', // Could be enhanced with real data
            flag: '🌍', // Default flag
            age: 25, // Default age
            gender: 'F', // Default gender
            isOnline: true, // Default online status
            lastSeen: DateTime.now(),
            interests: ['Language Exchange', 'Chat'], // Default interests
            nativeLanguage: 'Unknown',
            learningLanguage: 'English',
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(user: chatUser),
            ),
          );
        },
      ),
    );
  }
}
