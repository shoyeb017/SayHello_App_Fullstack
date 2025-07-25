import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      onSelected: (String languageCode) {
        languageProvider.setLocale(Locale(languageCode));
      },
      tooltip:
          AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageProvider.getCurrentLanguageFlag(),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return LanguageProvider.supportedLanguages.map((language) {
          final isSelected =
              languageProvider.currentLocale.languageCode == language['code'];

          return PopupMenuItem<String>(
            value: language['code'],
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Text(language['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      language['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF7a54ff)
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: Color(0xFF7a54ff), size: 20),
                ],
              ),
            ),
          );
        }).toList();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: isDark ? Colors.grey.shade800 : Colors.white,
    );
  }
}
