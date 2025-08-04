import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/settings_provider.dart';

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
  String selectedLang = "";
  bool isSelectingSource = true;

  final Map<String, Map<String, String>> translations = {
    "hello": {
      "English": "Hello",
      "Spanish": "Hola",
      "Japanese": "こんにちは",
      "Korean": "안녕하세요",
      "Bengali": "হ্যালো",
    },
    "goodbye": {
      "English": "Goodbye",
      "Spanish": "Adiós",
      "Japanese": "さようなら",
      "Korean": "안녕히 가세요",
      "Bengali": "বিদায়",
    },
    "thank you": {
      "English": "Thank you",
      "Spanish": "Gracias",
      "Japanese": "ありがとう",
      "Korean": "감사합니다",
      "Bengali": "ধন্যবাদ",
    },
    "yes": {
      "English": "Yes",
      "Spanish": "Sí",
      "Japanese": "はい",
      "Korean": "네",
      "Bengali": "হ্যাঁ",
    },
    "no": {
      "English": "No",
      "Spanish": "No",
      "Japanese": "いいえ",
      "Korean": "아니요",
      "Bengali": "না",
    },
    "please": {
      "English": "Please",
      "Spanish": "Por favor",
      "Japanese": "お願いします",
      "Korean": "부탁합니다",
      "Bengali": "অনুগ্রহ করে",
    },
    "excuse me": {
      "English": "Excuse me",
      "Spanish": "Disculpe",
      "Japanese": "すみません",
      "Korean": "실례합니다",
      "Bengali": "দুঃখিত",
    },
    "good morning": {
      "English": "Good morning",
      "Spanish": "Buenos días",
      "Japanese": "おはようございます",
      "Korean": "좋은 아침",
      "Bengali": "সুপ্রভাত",
    },
    "good night": {
      "English": "Good night",
      "Spanish": "Buenas noches",
      "Japanese": "おやすみなさい",
      "Korean": "안녕히 주무세요",
      "Bengali": "শুভ রাত্রি",
    },
    "how are you": {
      "English": "How are you?",
      "Spanish": "¿Cómo estás?",
      "Japanese": "元気ですか？",
      "Korean": "어떻게 지내세요?",
      "Bengali": "আপনি কেমন আছেন?",
    },
  };

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

  void _translate() {
    String text = _inputController.text.trim().toLowerCase();
    setState(() {
      if (translations.containsKey(text)) {
        translatedText =
            translations[text]![targetLang] ?? "Translation not available";
      } else {
        translatedText = "Translation not available for this phrase";
      }
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
      translatedText = "";
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
                        Text(
                          sourceLang,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
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
                    onPressed: _translate,
                    icon: const Icon(Icons.translate),
                    label: Text(AppLocalizations.of(context)!.translate),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        translatedText,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
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
