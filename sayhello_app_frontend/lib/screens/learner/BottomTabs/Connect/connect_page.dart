import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../l10n/app_localizations.dart';
import 'others_profile_page.dart';
import '../../Notifications/notifications.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/learner_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../models/learner.dart';
import '../../Chat/chat.dart';

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

  // Search debouncer
  Timer? _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _loadLanguagePartners();
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Load language partners from backend based on current user's learning language
  Future<void> _loadLanguagePartners() async {
    if (!mounted) return;

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
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Debounced search to prevent rapid setState calls
  void _onSearchChanged() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  /// Apply all filters to the learner list
  void _applyFilters() {
    if (!mounted) return; // Early return if widget is disposed

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

    if (mounted) {
      setState(() {
        _filteredLearners = filtered;
      });
    }
  }

  /// Build main content with backend data integration
  Widget _buildMainContent(bool isDark, Color textColor, Color dividerColor) {
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
                                _getLanguageCode(learner.nativeLanguage),
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
                                _getLanguageCode(learner.learningLanguage),
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

  /// Helper method to get language code
  String _getLanguageCode(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'EN';
      case 'spanish':
        return 'ES';
      case 'japanese':
        return 'JP';
      case 'korean':
        return 'KR';
      case 'french':
        return 'FR';
      case 'german':
        return 'DE';
      case 'chinese':
        return 'ZH';
      case 'arabic':
        return 'AR';
      case 'portuguese':
        return 'PT';
      case 'italian':
        return 'IT';
      case 'russian':
        return 'RU';
      case 'hindi':
        return 'HI';
      case 'bengali':
        return 'BN';
      case 'urdu':
        return 'UR';
      case 'dutch':
        return 'NL';
      case 'thai':
        return 'TH';
      case 'vietnamese':
        return 'VI';
      case 'turkish':
        return 'TR';
      case 'polish':
        return 'PL';
      case 'swedish':
        return 'SV';
      case 'norwegian':
        return 'NO';
      case 'danish':
        return 'DA';
      case 'finnish':
        return 'FI';
      case 'greek':
        return 'EL';
      case 'hebrew':
        return 'HE';
      case 'hungarian':
        return 'HU';
      case 'czech':
        return 'CS';
      case 'slovak':
        return 'SK';
      case 'ukrainian':
        return 'UK';
      case 'romanian':
        return 'RO';
      case 'bulgarian':
        return 'BG';
      case 'croatian':
        return 'HR';
      case 'serbian':
        return 'SR';
      case 'slovenian':
        return 'SL';
      case 'estonian':
        return 'ET';
      case 'latvian':
        return 'LV';
      case 'lithuanian':
        return 'LT';
      case 'maltese':
        return 'MT';
      case 'irish':
        return 'GA';
      case 'welsh':
        return 'CY';
      case 'scottish gaelic':
        return 'GD';
      case 'catalan':
        return 'CA';
      case 'basque':
        return 'EU';
      case 'galician':
        return 'GL';
      default:
        // If not found, return first 2 characters of the language name in uppercase
        return language.length >= 2
            ? language.substring(0, 2).toUpperCase()
            : language.toUpperCase();
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
    double tempAgeStart = _ageStart;
    double tempAgeEnd = _ageEnd;
    String? tempSelectedGender = _selectedGender;
    String? tempSelectedRegion = _selectedRegion;
    String? tempSelectedProficiency = _selectedProficiency;

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
                    // Language Proficiency Filter
                    const Text(
                      'Language Level',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          [
                            'Beginner',
                            'Elementary',
                            'Intermediate',
                            'Advanced',
                            'Native',
                          ].asMap().entries.map((entry) {
                            final level = entry.value;
                            final isSelected = tempSelectedProficiency == level;
                            return GestureDetector(
                              onTap: () => setState(
                                () => tempSelectedProficiency = level,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 20,
                                    color: isSelected
                                        ? Colors.purple
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    level,
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Age Range
                    const Text(
                      'Age Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tempAgeStart.toInt().toString()),
                        Text('${tempAgeEnd.toInt()}+'),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(tempAgeStart, tempAgeEnd),
                      min: 16,
                      max: 100,
                      divisions: 84,
                      labels: RangeLabels(
                        tempAgeStart.round().toString(),
                        tempAgeEnd.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          tempAgeStart = values.start;
                          tempAgeEnd = values.end;
                        });
                      },
                      activeColor: Colors.purple,
                    ),
                    const SizedBox(height: 24),

                    // Region Filter
                    const Text(
                      'Region of Language Partner',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempSelectedRegion,
                      hint: const Text('Select Region'),
                      items: ['USA', 'Spain', 'Japan', 'Korea', 'Bangladesh']
                          .map(
                            (region) => DropdownMenuItem(
                              value: region,
                              child: Text(region),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          tempSelectedRegion = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Gender Filter
                    const Text(
                      'Gender',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['All', 'Male', 'Female'].asMap().entries.map((
                        entry,
                      ) {
                        final gender = entry.value;
                        IconData icon;
                        if (gender == 'Male') {
                          icon = Icons.male;
                        } else if (gender == 'Female') {
                          icon = Icons.female;
                        } else {
                          icon = Icons.group;
                        }

                        final isSelected = tempSelectedGender == gender;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => tempSelectedGender = gender),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
                                  size: 32,
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  gender,
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
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempAgeStart = 18;
                      tempAgeEnd = 90;
                      tempSelectedGender = null;
                      tempSelectedRegion = null;
                      tempSelectedProficiency = null;
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
                    // Apply the filters to the main state
                    if (mounted) {
                      _ageStart = tempAgeStart;
                      _ageEnd = tempAgeEnd;
                      _selectedGender = tempSelectedGender;
                      _selectedRegion = tempSelectedRegion;
                      _selectedProficiency = tempSelectedProficiency;
                      _applyFilters();
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
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
              // Settings icon
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

              // Notification icon
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final unreadCount = notificationProvider.unreadCount;
                  return Stack(
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
                      if (unreadCount > 0)
                        Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
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
                  );
                },
              ),

              IconButton(
                icon: Icon(Icons.more_vert, color: textColor),
                onPressed: () {
                  _showAdvancedFilterDialog(context);
                },
              ),
            ],
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Filter Tabs
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
                      if (mounted) {
                        setState(() {
                          selectedTopTabIndex = index;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _onSearchChanged(),
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
                            if (mounted) {
                              _applyFilters();
                            }
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

          // Status and Statistics
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

          // Main Content
          Expanded(child: _buildMainContent(isDark, textColor, dividerColor)),
        ],
      ),
    );
  }
}
