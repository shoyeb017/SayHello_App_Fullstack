import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'others_profile_page.dart';
import '../../Notifications/notifications.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/learner_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../models/learner.dart';
import '../../Chat/chat.dart';

class Partner {
  final String name;
  final String message;
  final String avatar;
  final String gender; // 'male' or 'female'
  final List<String> interests;
  final String nativeLanguage;
  final String learningLanguage;
  final String region;
  final String city;

  Partner({
    required this.name,
    required this.message,
    required this.avatar,
    required this.gender,
    this.interests = const [],
    required this.nativeLanguage,
    required this.learningLanguage,
    required this.region,
    required this.city,
  });
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({Key? key}) : super(key: key);

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  int selectedTopTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Backend state
  List<Learner> _allLearners = [];
  List<Learner> _filteredLearners = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  double _ageStart = 18;
  double _ageEnd = 90;
  String? _selectedGender;
  String? _selectedRegion;
  String? _selectedProficiency;

  @override
  void initState() {
    super.initState();
    _loadLanguagePartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load language partners from backend based on current user's learning language
  Future<void> _loadLanguagePartners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final learnerProvider = Provider.of<LearnerProvider>(
        context,
        listen: false,
      );
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        throw Exception('No user logged in');
      }

      final currentUser = authProvider.currentUser as Learner;

      // Load current user's chats to filter out existing chat partners
      await chatProvider.loadUserChats(currentUser.id);
      final existingChatUserIds = <String>{};

      // Collect all user IDs that current user already has chats with
      for (final chatWithMessage in chatProvider.userChats) {
        final chat = chatWithMessage.chat;
        if (chat.user1Id == currentUser.id) {
          existingChatUserIds.add(chat.user2Id);
        } else if (chat.user2Id == currentUser.id) {
          existingChatUserIds.add(chat.user1Id);
        }
      }

      // Get learners whose native language matches current user's learning language
      if (currentUser.learningLanguage.isNotEmpty) {
        final partners = await learnerProvider.getLearnersByLanguage(
          currentUser.learningLanguage,
        );

        // Filter out current user and users with existing chats
        _allLearners = partners
            .where(
              (learner) =>
                  learner.id != currentUser.id &&
                  !existingChatUserIds.contains(learner.id),
            )
            .toList();
        _applyFilters();
      } else {
        _allLearners = [];
        _filteredLearners = [];
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Apply all filters to the learner list
  void _applyFilters() {
    List<Learner> filtered = List.from(_allLearners);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      String searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((learner) {
        return learner.name.toLowerCase().contains(searchTerm) ||
            (learner.bio?.toLowerCase().contains(searchTerm) ?? false) ||
            learner.interests.any(
              (interest) => interest.toLowerCase().contains(searchTerm),
            );
      }).toList();
    }

    // Apply age filter
    final currentDate = DateTime.now();
    filtered = filtered.where((learner) {
      final age = currentDate.difference(learner.dateOfBirth).inDays ~/ 365;
      return age >= _ageStart && age <= _ageEnd;
    }).toList();

    // Apply gender filter
    if (_selectedGender != null && _selectedGender != 'All') {
      filtered = filtered
          .where(
            (learner) =>
                learner.gender.toLowerCase() == _selectedGender!.toLowerCase(),
          )
          .toList();
    }

    // Apply region filter
    if (_selectedRegion != null) {
      filtered = filtered
          .where((learner) => learner.country == _selectedRegion)
          .toList();
    }

    // Apply proficiency filter
    if (_selectedProficiency != null) {
      filtered = filtered
          .where((learner) => learner.languageLevel == _selectedProficiency)
          .toList();
    }

    // Apply top tab filters
    switch (selectedTopTabIndex) {
      case 1: // Shared Interests
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          final currentUser = authProvider.currentUser as Learner;
          filtered = filtered.where((learner) {
            return learner.interests.any(
              (interest) => currentUser.interests.contains(interest),
            );
          }).toList();
        }
        break;
      case 2: // Nearby (same country)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          final currentUser = authProvider.currentUser as Learner;
          filtered = filtered
              .where((learner) => learner.country == currentUser.country)
              .toList();
        }
        break;
      case 3: // Gender (opposite gender)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          final currentUser = authProvider.currentUser as Learner;
          filtered = filtered
              .where((learner) => learner.gender != currentUser.gender)
              .toList();
        }
        break;
      default: // All
        break;
    }

    setState(() {
      _filteredLearners = filtered;
    });
  }

  /// Build main content with backend data integration
  Widget _buildMainContentWithBackend(
    bool isDark,
    Color textColor,
    Color dividerColor,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Error loading language partners',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLanguagePartners,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredLearners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No language partners found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLanguagePartners,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filteredLearners.length,
      separatorBuilder: (_, __) => Divider(color: dividerColor, height: 1),
      itemBuilder: (context, index) {
        final learner = _filteredLearners[index];
        return _buildLearnerCard(learner, isDark: isDark);
      },
    );
  }

  /// Build learner card with backend data
  Widget _buildLearnerCard(Learner learner, {required bool isDark}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OthersProfilePage(
              userId: learner.id,
              name: learner.name,
              avatar: learner.profileImage ?? '',
              nativeLanguage: learner.nativeLanguage,
              learningLanguage: learner.learningLanguage,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      learner.profileImage != null &&
                          learner.profileImage!.isNotEmpty
                      ? NetworkImage(learner.profileImage!)
                      : null,
                  child:
                      learner.profileImage == null ||
                          learner.profileImage!.isEmpty
                      ? Text(
                          learner.name.isNotEmpty
                              ? learner.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Learner Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Age with Gender
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              learner.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: learner.gender.toLowerCase() == 'female'
                                  ? Color(0xFFFEEDF7)
                                  : Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              learner.gender.toLowerCase() == 'male'
                                  ? Icons.male
                                  : Icons.female,
                              color: learner.gender.toLowerCase() == 'male'
                                  ? Color(0xFF1976D2)
                                  : Color(0xFFD619A8),
                              size: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Languages
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                learner.nativeLanguage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.sync_alt,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.purple,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                learner.learningLanguage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Bio (if available)
                      if (learner.bio != null && learner.bio!.isNotEmpty)
                        Text(
                          learner.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 6),

                      // Interests
                      if (learner.interests.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: -6,
                          children: learner.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Wave icon top-right
            Positioned(
              top: 28,
              right: 10,
              child: GestureDetector(
                onTap: () => _navigateToChat(learner),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to chat page with the selected learner
  Future<void> _navigateToChat(Learner learner) async {
    try {
      // Create ChatUser from Learner for navigation
      final chatUser = ChatUser(
        id: learner.id,
        name: learner.name,
        avatarUrl: learner.profileImage ?? '',
        country: learner.country,
        flag: _getCountryFlag(learner.country),
        age: _calculateAge(learner.dateOfBirth),
        gender: learner.gender == 'male' ? 'M' : 'F',
        isOnline: true, // Could be enhanced with real online status
        lastSeen: DateTime.now(), // Could be enhanced with real last seen
        interests: learner.interests,
        nativeLanguage: learner.nativeLanguage,
        learningLanguage: learner.learningLanguage,
      );

      // Navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatDetailPage(user: chatUser)),
      );
    } catch (e) {
      print('Error navigating to chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Helper method to get country flag
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

  /// Helper method to calculate age
  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Show advanced filter dialog
  void _showAdvancedFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Advanced Filters'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age Range
                    const Text(
                      'Age Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(_ageStart, _ageEnd),
                      min: 16,
                      max: 100,
                      divisions: 84,
                      labels: RangeLabels(
                        _ageStart.round().toString(),
                        _ageEnd.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _ageStart = values.start;
                          _ageEnd = values.end;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender Filter
                    const Text(
                      'Gender',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      hint: const Text('Select Gender'),
                      items: ['All', 'Male', 'Female', 'Other']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country/Region Filter
                    const Text(
                      'Country/Region',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter country name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _selectedRegion = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Language Proficiency Filter
                    const Text(
                      'Language Proficiency',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedProficiency,
                      hint: const Text('Select Proficiency Level'),
                      items: ['Beginner', 'Intermediate', 'Advanced', 'Native']
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProficiency = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _ageStart = 18;
                      _ageEnd = 90;
                      _selectedGender = null;
                      _selectedRegion = null;
                      _selectedProficiency = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> get topTabs => [
    AppLocalizations.of(context)!.all,
    AppLocalizations.of(context)!.sharedInterests,
    AppLocalizations.of(context)!.nearby,
    AppLocalizations.of(context)!.gender,
  ];

  final List<Partner> allPartners = [
    Partner(
      name: 'Yusuke',
      message: 'My name is Yusuke from Japan...',
      avatar: 'https://picsum.photos/seed/b/60',
      gender: 'male',
      interests: ['Football', 'Basketball', 'Reading'],
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      region: 'Asia',
      city: 'Tokyo',
    ),
    Partner(
      name: 'かえде',
      message: 'Just joined HT\nTap to say Hi!',
      avatar: 'https://picsum.photos/seed/a/60',
      gender: 'female',
      interests: ['Swimming', 'Music'],
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      region: 'Asia',
      city: 'Osaka',
    ),
    Partner(
      name: '藤井徳',
      message: 'Just joined HT\nTap to say Hi!',
      avatar: 'https://picsum.photos/seed/c/60',
      gender: 'male',
      interests: ['Cycling', 'Photography'],
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      region: 'Asia',
      city: 'Kyoto',
    ),
    Partner(
      name: 'Sasuke',
      message: 'My name is Sasuke from Tokyo and I love anime!',
      avatar: 'https://picsum.photos/seed/e/60',
      gender: 'male',
      interests: ['Soccer', 'Basketball', 'Anime'],
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      region: 'Asia',
      city: 'Tokyo',
    ),
    Partner(
      name: 'えかえで',
      message: 'Just joined HT. Tap to say Hi! I love to play games.',
      avatar: 'https://picsum.photos/seed/g/60',
      gender: 'female',
      interests: ['Gaming', 'Singing'],
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      region: 'Asia',
      city: 'Hiroshima',
    ),
    Partner(
      name: '井徳',
      message:
          'Hi! Everyone, I am new here. I am a big fan of anime and manga.',
      avatar: 'https://picsum.photos/seed/h/60',
      gender: 'female',
      interests: ['Chess', 'Reading'],
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      region: 'Asia',
      city: 'Nagoya',
    ),
  ];

  List<Partner> get filteredPartners {
    List<Partner> filtered = allPartners;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      String searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchTerm) ||
                p.message.toLowerCase().contains(searchTerm) ||
                p.interests.any(
                  (interest) => interest.toLowerCase().contains(searchTerm),
                ),
          )
          .toList();
    }

    // Apply top tab filters
    switch (selectedTopTabIndex) {
      case 1: // Shared Interests
        // This will be implemented with backend integration
        return filtered;
      case 2: // Nearby
        // This will be implemented with backend integration
        return filtered;
      case 3: // Gender (opposite gender)
        // This will be implemented with user gender preference
        return filtered;
      default: // All
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final chipSelectedBg = isDark
        ? Colors.grey.shade800
        : const Color(0xFFf0f0f0);
    final chipborderColor = isDark ? Color(0xFF151515) : Colors.white;
    final chipUnselectedText = isDark
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              // 🔧 SETTINGS ICON - This is the settings button in the app bar
              // Click this to open the settings bottom sheet with theme and language options
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () =>
                    SettingsProvider.showSettingsBottomSheet(context),
              ),

              const SizedBox(width: 40),

              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.findPartners,
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

              IconButton(
                icon: Icon(Icons.more_vert, color: textColor),
                onPressed: () {
                  showSearchFilterSheet(context);
                },
              ),
            ],
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Filter Tabs with Backend Integration
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: topTabs.length,
              itemBuilder: (context, index) {
                final selected = index == selectedTopTabIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      topTabs[index],
                      style: TextStyle(
                        color: selected ? textColor : chipUnselectedText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    selected: selected,
                    backgroundColor: Colors.transparent,
                    selectedColor: chipSelectedBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: chipborderColor),
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedTopTabIndex = index;
                        _applyFilters(); // Apply backend filters
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Search Field with Backend Integration
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    _applyFilters(), // Apply backend filters on search
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPeople,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        onPressed: () {
                          _showAdvancedFilterDialog(context);
                        },
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),

          // Backend Status and Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.currentUser != null) {
                      final currentUser = authProvider.currentUser as Learner;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF311c85) : Color(0xFFefecff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Learning: ${currentUser.learningLanguage}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7758f3),
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const Spacer(),
                if (!_isLoading && _error == null)
                  Text(
                    '${_filteredLearners.length} partners found',
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: _loadLanguagePartners,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Main Content with Backend Data
          Expanded(
            child: _buildMainContentWithBackend(
              isDark,
              textColor,
              dividerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget languageTab(
    String label, {
    bool selected = false,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? Color(0xFF311c85) : Color(0xFFefecff))
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected
              ? Color(0xFF7758f3)
              : (isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget partnerCard(Partner partner, {required bool isDark}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OthersProfilePage(
              userId: partner.name, // Using name as ID for demo
              name: partner.name,
              avatar: partner.avatar,
              nativeLanguage: partner.nativeLanguage,
              learningLanguage: partner.learningLanguage,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(partner.avatar),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Gender
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              partner.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: partner.gender == 'female'
                                  ? Color(0xFFFEEDF7)
                                  : Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              partner.gender == 'male'
                                  ? Icons.male
                                  : Icons.female,
                              color: partner.gender == 'male'
                                  ? Color(0xFF1976D2)
                                  : Color(0xFFD619A8),
                              size: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Languages
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                partner.nativeLanguage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.sync_alt,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.purple,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                partner.learningLanguage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Message
                      Text(
                        partner.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Interests
                      Wrap(
                        spacing: 4,
                        runSpacing: -6,
                        children: partner.interests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Wave icon top-right
            Positioned(
              top: 28,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  // For dummy partners, you could show a message or navigate to a demo chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'This is a demo partner. Try the real partners above!',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This widget is shown when clicking the filter/search icon

void showSearchFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // So you can add spacing
    builder: (context) => Padding(
      padding: const EdgeInsets.only(
        top: 40,
      ), // 👈 Push the sheet down from top
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const SearchFilterSheet(),
      ),
    ),
  );
}

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({Key? key}) : super(key: key);

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  double _currentAgeStart = 18;
  double _currentAgeEnd = 90;
  int _selectedGenderIndex = 0;
  final List<String> genders = ['All', 'Male', 'Female'];

  List<String> get localizedGenders => [
    AppLocalizations.of(context)!.all,
    AppLocalizations.of(context)!.male,
    AppLocalizations.of(context)!.female,
  ];

  // Expanded regions and cities for the 5 languages
  final List<String> regions = [
    'Asia',
    'Europe',
    'North America',
    'South America',
    'Africa',
    'Oceania',
  ];

  final Map<String, List<String>> citiesByRegion = {
    'Asia': [
      'Tokyo',
      'Seoul',
      'Beijing',
      'Shanghai',
      'Dhaka',
      'Mumbai',
      'Bangkok',
      'Manila',
    ],
    'Europe': [
      'London',
      'Paris',
      'Berlin',
      'Madrid',
      'Rome',
      'Amsterdam',
      'Vienna',
      'Prague',
    ],
    'North America': [
      'New York',
      'Los Angeles',
      'Toronto',
      'Vancouver',
      'Mexico City',
      'Montreal',
    ],
    'South America': [
      'São Paulo',
      'Buenos Aires',
      'Lima',
      'Bogotá',
      'Santiago',
      'Caracas',
    ],
    'Africa': ['Cairo', 'Lagos', 'Cape Town', 'Nairobi', 'Casablanca', 'Tunis'],
    'Oceania': [
      'Sydney',
      'Melbourne',
      'Auckland',
      'Brisbane',
      'Perth',
      'Adelaide',
    ],
  };

  String? _selectedRegion;
  String? _selectedCity;
  int _selectedProficiency = 4;

  List<String> get availableCities {
    if (_selectedRegion == null) return [];
    return citiesByRegion[_selectedRegion] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                  Text(
                    AppLocalizations.of(context)!.search,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentAgeStart = 18;
                        _currentAgeEnd = 90;
                        _selectedGenderIndex = 0;
                        _selectedRegion = null;
                        _selectedCity = null;
                        _selectedProficiency = 4;
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.reset),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Proficiency levels
              Text(
                AppLocalizations.of(context)!.languageLevel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final titles = [
                    AppLocalizations.of(context)!.beginner,
                    AppLocalizations.of(context)!.elementary,
                    AppLocalizations.of(context)!.intermediate,
                    AppLocalizations.of(context)!.advanced,
                    AppLocalizations.of(context)!.proficient,
                  ];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedProficiency = index),
                    child: Column(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 20,
                          color: index <= _selectedProficiency
                              ? Colors.purple
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          titles[index],
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.age,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_currentAgeStart.toInt().toString()),
                  Text('${_currentAgeEnd.toInt()}+'),
                ],
              ),
              RangeSlider(
                values: RangeValues(_currentAgeStart, _currentAgeEnd),
                min: 18,
                max: 90,
                divisions: 72,
                onChanged: (values) {
                  setState(() {
                    _currentAgeStart = values.start;
                    _currentAgeEnd = values.end;
                  });
                },
                activeColor: Colors.purple,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.advancedSearch,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 6),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.regionOfLanguagePartner,
                  border: OutlineInputBorder(),
                ),
                value: _selectedRegion,
                items: regions.map((region) {
                  return DropdownMenuItem(value: region, child: Text(region));
                }).toList(),
                onChanged: (val) => setState(() {
                  _selectedRegion = val;
                  _selectedCity = null; // Reset city when region changes
                }),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.cityOfLanguagePartner,
                  border: OutlineInputBorder(),
                ),
                value: _selectedCity,
                items: availableCities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCity = val),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.gender,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(genders.length, (index) {
                  IconData icon;
                  if (genders[index] == 'Male') {
                    icon = Icons.male;
                  } else if (genders[index] == 'Female') {
                    icon = Icons.female;
                  } else {
                    icon = Icons.group;
                  }

                  final isSelected = _selectedGenderIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedGenderIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ), // ✅ More horizontal space
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.purple
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 40,
                            color: isSelected ? Colors.purple : Colors.grey,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizedGenders[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.search,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
