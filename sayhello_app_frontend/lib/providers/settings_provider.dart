import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class SettingsProvider {
  // 🔧 SETTINGS BOTTOM SHEET - This function shows the settings menu when you tap the settings icon
  static void showSettingsBottomSheet(
    BuildContext context
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final primaryColor = const Color(0xFF7A54FF);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Settings title
            Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // 🎨 THEME SETTING - This is the dark/light mode toggle in settings
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) => ListTile(
                  leading: Icon(
                    themeProvider.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: primaryColor,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.colorMode,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    themeProvider.themeMode == ThemeMode.dark
                        ? AppLocalizations.of(context)!.darkMode
                        : AppLocalizations.of(context)!.lightMode,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                  onTap: () {
                    bool toDark = themeProvider.themeMode != ThemeMode.dark;
                    themeProvider.toggleTheme(toDark);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🌐 LANGUAGE SETTING - This is the language selection option in settings
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.language, color: primaryColor),
                title: Text(
                  AppLocalizations.of(context)!.language,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.changeAppLanguage,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                onTap: () {
                  Navigator.pop(context); // Close settings
                  showLanguageSelector(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🌐 ENHANCED LANGUAGE SELECTOR - Shows languages with flags and native text
  static void showLanguageSelector(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Enhanced language list with flags and native names
    final languages = [
      {
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
        'flag': '🇺🇸',
        'localized': AppLocalizations.of(context)!.english,
      },
      {
        'code': 'es',
        'name': 'Spanish',
        'nativeName': 'Español',
        'flag': '🇪🇸',
        'localized': AppLocalizations.of(context)!.spanish,
      },
      {
        'code': 'ja',
        'name': 'Japanese',
        'nativeName': '日本語',
        'flag': '🇯🇵',
        'localized': AppLocalizations.of(context)!.japanese,
      },
      {
        'code': 'ko',
        'name': 'Korean',
        'nativeName': '한국어',
        'flag': '🇰🇷',
        'localized': AppLocalizations.of(context)!.korean,
      },
      {
        'code': 'bn',
        'name': 'Bengali',
        'nativeName': 'বাংলা',
        'flag': '🇧🇩',
        'localized': AppLocalizations.of(context)!.bangla,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          8,
        ), // Reduced padding
        titlePadding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          8,
        ), // Reduced padding
        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16,
        ), // Custom actions padding
        title: Row(
          children: [
            Icon(
              Icons.language,
              color: const Color(0xFF7A54FF),
              size: 22, // Reduced from 24 to 22
            ),
            const SizedBox(width: 6), // Reduced from 8 to 6
            Expanded(
              // Wrap the text in Expanded to prevent overflow
              child: Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Slightly reduced font size
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            // Add scroll view as backup
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseYourPreferredLanguage,
                  style: TextStyle(
                    fontSize: 12, // Reduced from 13 to 12
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12
                // Language selection list - All languages shown together without scrolling
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected =
                        languageProvider.currentLocale.languageCode ==
                        language['code'];

                    return InkWell(
                      onTap: () {
                        // Set the new language
                        languageProvider.setLocale(Locale(language['code']!));
                        Navigator.pop(context);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Text(language['flag']!),
                                const SizedBox(width: 8),
                                Text(
                                  '${AppLocalizations.of(context)!.languageChangedTo} ${language['localized']}',
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical:
                              10, // Reduced from 12 to 10 for even more compact layout
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            // Flag
                            Text(
                              language['flag']!,
                              style: const TextStyle(
                                fontSize: 20,
                              ), // Reduced from 22 to 20
                            ),
                            const SizedBox(width: 10), // Reduced from 12 to 10
                            // Language names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Localized name (in current app language)
                                  Text(
                                    language['localized']!,
                                    style: TextStyle(
                                      fontSize: 15, // Reduced from 16 to 15
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF7A54FF)
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Native name (in the language itself)
                                  if (language['nativeName'] !=
                                      language['localized'])
                                    Text(
                                      language['nativeName']!,
                                      style: TextStyle(
                                        fontSize: 12, // Reduced from 13 to 12
                                        color: isSelected
                                            ? const Color(
                                                0xFF7A54FF,
                                              ).withOpacity(0.8)
                                            : Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                            // Selection indicator
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7A54FF,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Color(0xFF7A54FF),
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.close,
              style: TextStyle(color: const Color(0xFF7A54FF)),
            ),
          ),
        ],
      ),
    );
  }
}
