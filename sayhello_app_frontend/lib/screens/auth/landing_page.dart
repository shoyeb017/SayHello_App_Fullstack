import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/language_selector.dart';
import '../../l10n/app_localizations.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollControllerLTR;
  late ScrollController _scrollControllerRTL;

  @override
  void initState() {
    super.initState();
    _scrollControllerLTR = ScrollController();
    _scrollControllerRTL = ScrollController();

    // Initialize RTL controller offset to maxScroll after first frame:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollControllerRTL.hasClients) {
        final maxScroll = _scrollControllerRTL.position.maxScrollExtent;
        _scrollControllerRTL.jumpTo(maxScroll);
      }
      _startAutoScrollLTR();
      _startAutoScrollRTL();
    });
  }

  void _startAutoScrollLTR() {
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      // faster by using 100ms interval
      if (_scrollControllerLTR.hasClients) {
        final maxScroll = _scrollControllerLTR.position.maxScrollExtent;
        final current =
            _scrollControllerLTR.offset + 1; // scroll 3 pixels per tick
        if (current >= maxScroll) {
          _scrollControllerLTR.jumpTo(0);
        } else {
          _scrollControllerLTR.jumpTo(current);
        }
      }
    });
  }

  void _startAutoScrollRTL() {
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_scrollControllerRTL.hasClients) {
        final maxScroll = _scrollControllerRTL.position.maxScrollExtent;
        final current =
            _scrollControllerRTL.offset -
            1; // scroll 3 pixels per tick backward
        if (current <= 0) {
          _scrollControllerRTL.jumpTo(maxScroll);
        } else {
          _scrollControllerRTL.jumpTo(current);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollControllerLTR.dispose();
    _scrollControllerRTL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF7a54ff)
                                : Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.practiceLanguages,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.meetFriends,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Language selector
                  const LanguageSelector(),
                  // Theme toggle button
                  IconButton(
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      bool toDark = themeProvider.themeMode != ThemeMode.dark;
                      themeProvider.toggleTheme(toDark);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 60,
              child: ListView(
                controller: _scrollControllerLTR,
                scrollDirection: Axis.horizontal,
                children: _buildFlagBubbles(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 60,
              child: ListView(
                controller: _scrollControllerRTL,
                scrollDirection: Axis.horizontal,
                // reverse: true,  <-- REMOVE THIS
                children: _buildFlagBubbles(),
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/learner-signin');
                    },
                    icon: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.iAmLearner,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7a54ff),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/instructor-signin');
                    },
                    icon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF7a54ff),
                      size: 24,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.iAmInstructor,
                      style: TextStyle(color: Color(0xFF7a54ff), fontSize: 20),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7a54ff)),
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text.rich(
              TextSpan(
                text:
                    'Your first login creates your account, and in doing so you agree to our ',
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFlagBubbles() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {
        'flag': '🇨🇳',
        'text': '你好',
        'image': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'flag': '🇧🇷',
        'text': 'Olá!',
        'image': 'https://i.pravatar.cc/150?img=2',
      },
      {
        'flag': '🇯🇵',
        'text': 'こんにちは',
        'image': 'https://i.pravatar.cc/150?img=3',
      },
      {
        'flag': '🇫🇷',
        'text': 'Bonjour!',
        'image': 'https://i.pravatar.cc/150?img=4',
      },
      {
        'flag': '🇰🇷',
        'text': '안녕하세요',
        'image': 'https://i.pravatar.cc/150?img=5',
      },
      {
        'flag': '🇪🇬',
        'text': 'أهلاً',
        'image': 'https://i.pravatar.cc/150?img=6',
      },
      {
        'flag': '🇩🇪',
        'text': 'Hallo',
        'image': 'https://i.pravatar.cc/150?img=7',
      },
      {
        'flag': '🇮🇹',
        'text': 'Ciao',
        'image': 'https://i.pravatar.cc/150?img=8',
      },
      {
        'flag': '🇪🇸',
        'text': '¡Hola!',
        'image': 'https://i.pravatar.cc/150?img=9',
      },
      {
        'flag': '🇷🇺',
        'text': 'Привет',
        'image': 'https://i.pravatar.cc/150?img=10',
      },
      {
        'flag': '🇮🇳',
        'text': 'नमस्ते',
        'image': 'https://i.pravatar.cc/150?img=11',
      },
      {
        'flag': '🇹🇷',
        'text': 'Merhaba',
        'image': 'https://i.pravatar.cc/150?img=12',
      },
      {
        'flag': '🇹🇭',
        'text': 'สวัสดี',
        'image': 'https://i.pravatar.cc/150?img=13',
      },
      {
        'flag': '🇲🇽',
        'text': '¡Qué tal!',
        'image': 'https://i.pravatar.cc/150?img=14',
      },
      {
        'flag': '🇸🇦',
        'text': 'مرحبا',
        'image': 'https://i.pravatar.cc/150?img=15',
      },
      {
        'flag': '🇧🇩',
        'text': 'হ্যালো',
        'image': 'https://i.pravatar.cc/150?img=16',
      },
      {
        'flag': '🇻🇳',
        'text': 'Xin chào',
        'image': 'https://i.pravatar.cc/150?img=17',
      },
      {
        'flag': '🇬🇧',
        'text': 'Hello!',
        'image': 'https://i.pravatar.cc/150?img=18',
      },
      {
        'flag': '🇺🇸',
        'text': 'Hey!',
        'image': 'https://i.pravatar.cc/150?img=19',
      },
      {
        'flag': '🇵🇭',
        'text': 'Kumusta',
        'image': 'https://i.pravatar.cc/150?img=20',
      },
    ];

    return items.map((item) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar + Flag Stack
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(item['image']!),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    child: Text(
                      item['flag']!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 1),
            // Chat bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black12,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item['text']!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
