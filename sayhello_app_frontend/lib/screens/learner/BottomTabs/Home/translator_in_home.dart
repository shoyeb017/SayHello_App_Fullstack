import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../services/azure_translator_service.dart';

class TranslatorInHome extends StatefulWidget {
  const TranslatorInHome({super.key});

  @override
  State<TranslatorInHome> createState() => _TranslatorInHomeState();
}

class _TranslatorInHomeState extends State<TranslatorInHome> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String sourceLang = "English";
  String targetLang = "Japanese";
  String translatedText = "";
  String transliteratedText = "";
  String selectedLang = "";
  bool isSelectingSource = true;
  bool isTranslating = false;
  bool isDetectingLanguage = false;
  bool isAzureConfigured = false;

  @override
  void initState() {
    super.initState();
    _checkAzureConfiguration();
  }

  Future<void> _checkAzureConfiguration() async {
    final configured = await AzureTranslatorService.isConfigured();
    setState(() {
      isAzureConfigured = configured;
    });
  }

  final List<String> allLanguages = [
    "English",
    "Spanish",
    "Japanese",
    "Korean",
    "Bengali",
  ];

  String _getSubtitle(String lang) {
    switch (lang) {
      case "English":
        return "English";
      case "Spanish":
        return "Español";
      case "Japanese":
        return "日本語";
      case "Korean":
        return "한국어";
      case "Bengali":
        return "বাংলা";
      default:
        return "";
    }
  }

  void _translate() async {
    String text = _inputController.text.trim();

    if (text.isEmpty) {
      setState(() {
        translatedText = "";
        transliteratedText = "";
      });
      return;
    }

    setState(() {
      isTranslating = true;
      translatedText = "";
      transliteratedText = "";
    });

    try {
      // Get translation
      final result = await AzureTranslatorService.translateText(
        text: text,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );

      // Get transliteration if available
      String? transliteration;
      try {
        transliteration = await AzureTranslatorService.transliterateText(
          text: result,
          language: targetLang,
        );
      } catch (e) {
        // Transliteration failed, but translation succeeded
        transliteration = null;
      }

      setState(() {
        translatedText = result;
        transliteratedText = transliteration ?? "";
        isTranslating = false;
      });
    } catch (e) {
      setState(() {
        translatedText = "Translation failed: ${e.toString()}";
        transliteratedText = "";
        isTranslating = false;
      });
    }
  }

  void _detectLanguage() async {
    String text = _inputController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      isDetectingLanguage = true;
    });

    try {
      final detectedLang = await AzureTranslatorService.detectLanguage(text);

      if (detectedLang != 'Unknown' && allLanguages.contains(detectedLang)) {
        setState(() {
          sourceLang = detectedLang;
          isDetectingLanguage = false;
        });

        // Show snackbar to inform user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detected language: $detectedLang'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          isDetectingLanguage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not detect language'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isDetectingLanguage = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
      translatedText = "";
      transliteratedText = "";
      _inputController.clear();
    });
  }

  void _openLanguageSelector(BuildContext context, bool isSource) {
    setState(() {
      isSelectingSource = isSource;
      selectedLang = isSource ? sourceLang : targetLang;
      _searchController.clear();
    });
    Scaffold.of(context).openEndDrawer();
  }

  void _applyLanguageSelection() {
    setState(() {
      if (isSelectingSource) {
        sourceLang = selectedLang;
      } else {
        targetLang = selectedLang;
      }
    });
    Navigator.pop(context);
  }

  void _copyToClipboard(String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type copied to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<String> filteredLanguages = allLanguages
        .where(
          (lang) =>
              lang.toLowerCase().contains(_searchController.text.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // prevents default drawer icon
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // goes back to the previous screen
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.translate,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 🔧 SETTINGS ICON - This is the settings button in the app bar
          // Click this to open the settings bottom sheet with theme and language options
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => SettingsProvider.showSettingsBottomSheet(context),
          ),
        ], // forces NO icons on the right
      ),

      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                      ), // ✅ aligns text nicely
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  AppLocalizations.of(context)!.popular,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = filteredLanguages[index];
                    final isSelected = selectedLang == lang;
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(isDark ? 0.2 : 0.1)
                            : isDark
                            ? const Color(0xFF1f1f1f)
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedLang = lang;
                          });
                        },
                        title: Text(
                          lang,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.deepPurple
                                : isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          _getSubtitle(lang),
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.deepPurple)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _applyLanguageSelection,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.done,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final Color boxColor = isDark
              ? const Color(0xFF1F1F1F)
              : Colors.grey.shade200;
          final Color hintColor = isDark
              ? Colors.grey.shade600
              : Colors.grey.shade700;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Status Indicator
                  if (!isAzureConfigured)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo mode: Using fallback translations. Configure Azure credentials in the service code for full functionality.',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Language Selector Row
                  Container(
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Source Language Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLanguageSelector(context, true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                // color: langButtonColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sourceLang,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),

                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Swap Icon
                        IconButton(
                          onPressed: _swapLanguages,
                          icon: const Icon(Icons.swap_horiz),
                          tooltip: AppLocalizations.of(context)!.swapLanguages,
                        ),
                        // Target Language Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLanguageSelector(context, false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      targetLang,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),

                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Input Text Field Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sourceLang,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            // Detect Language Button
                            TextButton.icon(
                              onPressed: isDetectingLanguage
                                  ? null
                                  : _detectLanguage,
                              icon: isDetectingLanguage
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.deepPurple,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: Colors.deepPurple,
                                    ),
                              label: Text(
                                'Detect',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _inputController,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.of(
                              context,
                            )!.enterTextToTranslate,
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Translate Button
                  ElevatedButton.icon(
                    onPressed: isTranslating ? null : _translate,
                    icon: isTranslating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.translate),
                    label: Text(
                      isTranslating
                          ? 'Translating...'
                          : AppLocalizations.of(context)!.translate,
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Translated Text Output
                  if (translatedText.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Translation Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with language and copy button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    targetLang,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _copyToClipboard(
                                      translatedText,
                                      'Translation',
                                    ),
                                    icon: Icon(
                                      Icons.copy,
                                      size: 20,
                                      color: Colors.deepPurple,
                                    ),
                                    tooltip: 'Copy translation',
                                  ),
                                ],
                              ),
                              // Translation text
                              Text(
                                translatedText,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),

                        // Transliteration Container (if available)
                        if (transliteratedText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.deepPurple.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with label and copy button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.record_voice_over,
                                          size: 16,
                                          color: Colors.deepPurple,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pronunciation',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => _copyToClipboard(
                                        transliteratedText,
                                        'Pronunciation',
                                      ),
                                      icon: Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: Colors.deepPurple,
                                      ),
                                      tooltip: 'Copy pronunciation',
                                    ),
                                  ],
                                ),
                                // Transliteration text
                                Text(
                                  transliteratedText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.deepPurple.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Transliteration unavailable message (when translation exists but no transliteration)
                        if (translatedText.isNotEmpty &&
                            transliteratedText.isEmpty &&
                            isAzureConfigured &&
                            !translatedText.startsWith('Translation failed') &&
                            !translatedText.contains(
                              'Azure credentials not configured',
                            )) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pronunciation guide not available for this language',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
