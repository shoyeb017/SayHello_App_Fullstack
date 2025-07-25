import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  static const String _languageKey = 'selected_language';

  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];

  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);

      if (savedLanguageCode != null) {
        // Verify the saved language is still supported
        final isSupported = supportedLanguages.any(
          (lang) => lang['code'] == savedLanguageCode,
        );

        if (isSupported) {
          _currentLocale = Locale(savedLanguageCode);
          notifyListeners();
        }
      }
    } catch (e) {
      // If there's an error loading, stick with default (English)
      debugPrint('Error loading saved language: $e');
    }
  }

  // Save language preference and update locale
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;

      // Save to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, locale.languageCode);
      } catch (e) {
        debugPrint('Error saving language preference: $e');
      }

      notifyListeners();
    }
  }

  String getCurrentLanguageName() {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => supportedLanguages[0],
    );
    return language['name']!;
  }

  String getCurrentLanguageFlag() {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => supportedLanguages[0],
    );
    return language['flag']!;
  }

  static List<Locale> get supportedLocales {
    return supportedLanguages.map((lang) => Locale(lang['code']!)).toList();
  }
}
