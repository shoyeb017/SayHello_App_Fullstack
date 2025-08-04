import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'others_profile_page.dart';
import '../../Notifications/notifications.dart';
import '../../../../providers/settings_provider.dart';

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
  List<String> availableLanguages = []; // This will come from backend

  @override
  void initState() {
    super.initState();
    _loadAvailableLanguages();
  }

  // Placeholder method for backend integration
  void _loadAvailableLanguages() {
    // This will be replaced with actual backend call
    setState(() {
      availableLanguages = [
        'Japanese',
        'English',
        'Spanish',
        'Korean',
        'Bengali',
      ];
    });
  }

  List<String> get topTabs => [
    AppLocalizations.of(context)!.all,
    'Shared Interests', // Will be localized later
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
      name: 'かえで',
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
                      setState(() {
                        selectedTopTabIndex = index;
                      });
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
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search partners...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
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

          // Language Tabs (will be populated from backend)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Placeholder - will be replaced with backend data
                  languageTab('Japanese', selected: true, isDark: isDark),
                  // More language tabs will be added from backend
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Partner List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredPartners.length,
              separatorBuilder: (_, __) =>
                  Divider(color: dividerColor, height: 1),
              itemBuilder: (context, index) {
                final partner = filteredPartners[index];
                return partnerCard(partner, isDark: isDark);
              },
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
              child: Icon(Icons.waving_hand, color: Colors.purple, size: 24),
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
                  const Text(
                    'Search',
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
                  child: const Text(
                    'Search',
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
